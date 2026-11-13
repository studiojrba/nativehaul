import Foundation
@testable import nativehaul
import Testing

/// Spec §3.6: the beats, their real effects, skipping, and the replay.
@MainActor
struct OnboardingChatViewModelTests {
    private static let foundCount = 18
    private static let titles = ["Lantern Coast", "Moss & Ember", "Tideborn", "Velvet Orbit"]

    private func model(
        facts: OnboardingFacts = OnboardingFacts(),
        scan: OnboardingScan = .empty,
        finished: FinishFlag = FinishFlag()
    ) -> (OnboardingChatViewModel, MockOnboardingSetup) {
        let setup = MockOnboardingSetup(facts: facts, scanResult: scan)
        let viewModel = OnboardingChatViewModel(setup: setup, sleep: { _ in }, onFinish: { finished.isSet = true })
        return (viewModel, setup)
    }

    private func appMessages(_ viewModel: OnboardingChatViewModel) -> [String] {
        viewModel.typist.messages.filter { $0.sender == .app }.map(\.text)
    }

    private func action(_ id: String, in viewModel: OnboardingChatViewModel) throws -> OnboardingAction {
        try #require(viewModel.actions.first { $0.id == id })
    }

    private var scanOfFour: OnboardingScan {
        OnboardingScan(
            gameCount: Self.foundCount,
            titles: Self.titles,
            covers: Self.titles.map { ScanCover(id: UUID(), title: $0, imagePath: nil) }
        )
    }

    @Test func welcomeTypesTheSettledCopyThenOffersOneAnswer() async {
        let (viewModel, _) = model()
        await viewModel.start()
        #expect(appMessages(viewModel) == OnboardingScript.welcome)
        #expect(viewModel.isReady)
        #expect(viewModel.actions.map(\.label) == ["Sure, let’s go"])
        #expect(appMessages(viewModel).contains(
            "A few things worth knowing: I only ask for what I actually need, nothing extra."
        ))
        #expect(viewModel.beat.step == 0)
    }

    @Test func aSuggestedFolderIsAddedScannedAndTheRealCountAndTitlesAreSaid() async throws {
        var facts = OnboardingFacts()
        let folder = NSHomeDirectory() + "/Games"
        facts.suggestedFolder = folder
        let (viewModel, setup) = model(facts: facts, scan: scanOfFour)
        await viewModel.start()
        try await viewModel.choose(action("start", in: viewModel))
        #expect(viewModel.beat == .games)
        try await viewModel.choose(action("suggested", in: viewModel))
        #expect(setup.addedFolders == [folder])
        #expect(viewModel.beat == .found)
        #expect(viewModel.beat.step == 2)
        let said = appMessages(viewModel)
        #expect(said.contains(OnboardingScript.scanning))
        #expect(!viewModel.typist.isWaiting)
        #expect(!viewModel.typist.messages.contains { $0.text == OnboardingScript.scanningPlaceholder })
        #expect(said.contains("Ooh. 18 games in ~/Games."))
        #expect(said.contains("Lantern Coast, Moss & Ember, Tideborn… you’ve got excellent taste."))
        #expect(viewModel.typist.messages.contains { $0.sender == .user && $0.text == "Use ~/Games" })
    }

    @Test func zeroGamesGetsAnHonestFriendlyLine() async throws {
        var facts = OnboardingFacts()
        facts.suggestedFolder = NSHomeDirectory() + "/Games"
        let (viewModel, _) = model(facts: facts)
        await viewModel.start()
        try await viewModel.choose(action("start", in: viewModel))
        try await viewModel.choose(action("suggested", in: viewModel))
        #expect(appMessages(viewModel).contains("Hmm, no games in ~/Games yet."))
        #expect(!appMessages(viewModel).contains { $0.contains("excellent taste") })
        #expect(viewModel.actions.first?.label == "Okay, what’s next?")
    }

    @Test func thePickedFolderIsTheReplyAndCancellingKeepsTheQuestionOpen() async throws {
        let panel = MockFilePanel()
        let setup = MockOnboardingSetup()
        let viewModel = OnboardingChatViewModel(setup: setup, panel: panel, sleep: { _ in })
        await viewModel.start()
        try await viewModel.choose(action("start", in: viewModel))
        try await viewModel.choose(action("pick", in: viewModel))
        #expect(panel.folderAsks == 1)
        #expect(viewModel.beat == .games)
        #expect(viewModel.isReady)
        let url = URL(fileURLWithPath: NSHomeDirectory() + "/ROMs")
        panel.folder = url
        try await viewModel.choose(action("pick", in: viewModel))
        #expect(setup.addedFolders == [url.path(percentEncoded: false)])
        #expect(viewModel.typist.messages.contains { $0.text == "This one: ~/ROMs" })
    }

    @Test func hoveringOrFocusingTheSuggestedFolderPreviewsItAndLeavingResets() async throws {
        var facts = OnboardingFacts()
        facts.suggestedFolder = NSHomeDirectory() + "/Switch/Games"
        let (viewModel, _) = model(facts: facts)
        await viewModel.start()
        try await viewModel.choose(action("start", in: viewModel))
        #expect(viewModel.previewFolderLabel == nil)
        viewModel.hoveredActionID = "suggested"
        #expect(viewModel.previewFolderLabel == "~/Switch/Games")
        viewModel.hoveredActionID = "pick"
        #expect(viewModel.previewFolderLabel == nil)
        viewModel.hoveredActionID = nil
        #expect(viewModel.previewFolderLabel == nil)
    }

    @Test func soundsPlayFromTheFirstScreen() async throws {
        let played = SoundRecorder()
        let viewModel = OnboardingChatViewModel(
            setup: MockOnboardingSetup(),
            sleep: { _ in },
            playSound: { played.sounds.append($0) }
        )
        await viewModel.start()
        viewModel.hoveredActionID = "start"
        try await viewModel.choose(action("start", in: viewModel))
        viewModel.skipTour()
        #expect(played.sounds == [.navigate, .confirm, .back])
    }

    @Test func theBuildTutorialFollowsTheScanThenTheLibraryKeyThenEmulators() async {
        let (viewModel, _) = await OnboardingConversation.at(.buildIntro)
        #expect(appMessages(viewModel).contains(
            "The big feature here: you can build your Switch games natively with nxnative."
        ))
        var order: [OnboardingBeat] = [viewModel.beat]
        let forward = ["next", "default", "skip"]
        while viewModel.beat != .player, let next = viewModel.actions.first(where: { forward.contains($0.id) }) {
            await viewModel.choose(next)
            order.append(viewModel.beat)
        }
        #expect(order == [.buildIntro, .buildFolder, .buildBegin, .install, .buildLaunch, .buildNote, .keys, .player])
        let said = appMessages(viewModel).joined(separator: " ").lowercased()
        #expect(!said.contains("warm"))
        #expect(said.contains("begin build"))
    }

    @Test func theReplaySaysWhichFoldersAreSetUpInsteadOfReAsking() async throws {
        var facts = OnboardingFacts()
        facts.configuredFolders = [NSHomeDirectory() + "/Switch/Games"]
        let (viewModel, setup) = model(facts: facts, scan: scanOfFour)
        await viewModel.start()
        try await viewModel.choose(action("start", in: viewModel))
        #expect(appMessages(viewModel).contains("First up: your games. I’m already looking in ~/Switch/Games."))
        try await viewModel.choose(action("keep", in: viewModel))
        #expect(setup.scanCount == 1)
        #expect(setup.addedFolders.isEmpty)
        #expect(viewModel.beat == .found)
    }

    @Test func theExternalDriveIsOfferedOnlyWhenOneIsMounted() {
        var facts = OnboardingFacts()
        #expect(OnboardingScript.actions(for: .install, facts: facts).map(\.id) == ["default"])
        facts.externalVolume = VolumeInfo(name: "Fast SSD", mountPath: "/Volumes/Fast SSD", freeBytes: 1, totalBytes: 2)
        #expect(OnboardingScript.actions(for: .install, facts: facts).map(\.id) == ["default", "external"])
    }

    @Test func choosingTheExternalDriveWritesTheRealInstallLocation() async throws {
        var facts = OnboardingFacts()
        let drive = VolumeInfo(name: "Fast SSD", mountPath: "/Volumes/Fast SSD", freeBytes: 1, totalBytes: 2)
        facts.externalVolume = drive
        let (viewModel, setup) = await OnboardingConversation.at(.install, facts: facts)
        #expect(viewModel.beat == .install)
        try await viewModel.choose(action("external", in: viewModel))
        #expect(setup.installLocations == ["/Volumes/Fast SSD/nativehaul"])
        #expect(viewModel.beat == .buildLaunch)
    }

    @Test func theScanGroupingIsReadFromTheFolderScansDetails() {
        let full = ScanContents(details: "Base game · update v65536 · 3 DLC")
        #expect(full.summary == "Base + update + 3 DLC")
        #expect(full.hasExtras)
        #expect(!ScanContents(details: "Base game").hasExtras)
        #expect(ScanContents(details: "Base game · update").summary == "Base + update")
    }
}
