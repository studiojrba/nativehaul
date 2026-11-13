import Foundation
@testable import nativehaul
import Testing

/// Spec §3.6 keys, player and final beats: detect, don't re-demand (ADR 0021); never hint at sources; skipping is one
/// click; finishing saves the mode and never touches the appearance.
@MainActor
struct OnboardingKeysAndFinishTests {
    /// Runs a fresh conversation straight to `beat`'s question.
    private func conversation(
        at beat: OnboardingBeat,
        facts: OnboardingFacts = OnboardingFacts(),
        finished: FinishFlag = FinishFlag()
    ) async -> (OnboardingChatViewModel, MockOnboardingSetup) {
        let setup = MockOnboardingSetup(facts: facts)
        let viewModel = OnboardingChatViewModel(setup: setup, sleep: { _ in }, onFinish: { finished.isSet = true })
        await viewModel.start()
        let path: [String] = ["start", "later", "default", "skip", "next"]
        for id in path where viewModel.beat != beat {
            guard let action = viewModel.actions.first(where: { $0.id == id }) else { break }
            await viewModel.choose(action)
        }
        return (viewModel, setup)
    }

    private func said(_ viewModel: OnboardingChatViewModel) -> [String] {
        viewModel.typist.messages.filter { $0.sender == .app }.map(\.text)
    }

    @Test func aDetectedKeysFileIsAcknowledgedAndNeverAskedFor() async {
        var facts = OnboardingFacts()
        facts.detectedKeys = "/Users/demo/Switch/ProdKeys/prod.keys"
        let (viewModel, _) = await conversation(at: .keys, facts: facts)
        #expect(viewModel.beat == .keys)
        #expect(said(viewModel).contains("Found your keys file already. Lovely."))
        #expect(viewModel.actions.map(\.effect) == [.advance(.player)])
    }

    @Test func withoutKeysTheAskOffersAddHelpAndSkip() async {
        let (viewModel, _) = await conversation(at: .keys)
        #expect(said(viewModel).contains(
            "It comes from your own console and lets me build your Switch games. It never leaves this Mac."
        ))
        #expect(viewModel.actions.map(\.label) == ["Add my keys file", "Remind me what it is", "Skip for now"])
    }

    @Test func theExplainerNamesNoToolAndHintsAtNoSource() {
        let words = (OnboardingScript.keysHelp + OnboardingScript.keysSteps).joined(separator: " ").lowercased()
        for banned in ["lockpick", "homebrew", "dump", "download", "rcm", "hekate", "atmosphere"] {
            #expect(!words.contains(banned))
        }
        #expect(words.contains("your own console"))
    }

    @Test func skippingTheKeysIsOneClickAndSaidKindly() async {
        let (viewModel, setup) = await conversation(at: .player)
        #expect(viewModel.beat == .player)
        #expect(setup.placedKeys.isEmpty)
        #expect(said(viewModel).contains("No problem. Switch builds can wait until you have it."))
    }

    @Test func aPickedOrDroppedKeysFileIsPlacedThroughTheUserFileFlow() async throws {
        let (viewModel, setup) = await conversation(at: .keys)
        let add = try #require(viewModel.actions.first { $0.id == "add" })
        await viewModel.choose(add)
        #expect(viewModel.picker == .keys)
        await viewModel.picked(URL(fileURLWithPath: "/tmp/prod.keys"))
        #expect(setup.placedKeys == ["/tmp/prod.keys"])
        #expect(said(viewModel).contains("Got it — your keys file is in place."))

        let (dropModel, dropSetup) = await conversation(at: .keys)
        await dropModel.dropped(URL(fileURLWithPath: "/tmp/dropped.keys"))
        #expect(dropSetup.placedKeys == ["/tmp/dropped.keys"])
        #expect(dropModel.beat == .player)
    }

    @Test func thePlayerBeatNamesTheRealPlayersOrSaysNoneWereFound() async {
        var facts = OnboardingFacts()
        facts.players = MockPlayerDetector.preview.detectedPlayers()
        let (viewModel, _) = await conversation(at: .player, facts: facts)
        #expect(said(viewModel).contains(
            "Last bit of plumbing: I found RetroArch, Dolphin and the nxnative engine on this Mac."
        ))
        let (empty, _) = await conversation(at: .player)
        #expect(said(empty).contains { $0.contains("I didn’t find any emulator apps or the nxnative engine") })
    }

    @Test func choosingCouchSavesTheModeMarksDoneAndReturnsToTheShell() async throws {
        let finished = FinishFlag()
        let (viewModel, setup) = await conversation(at: .final, finished: finished)
        #expect(viewModel.beat == .final)
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "couch" }))
        #expect(setup.savedMode == .couch)
        #expect(setup.isCompleted)
        #expect(finished.isSet)
        #expect(viewModel.isFinished)
    }

    @Test func skippingTheTourFinishesAtOnceWithDefaults() async {
        let finished = FinishFlag()
        let setup = MockOnboardingSetup()
        let viewModel = OnboardingChatViewModel(setup: setup, sleep: { _ in }, onFinish: { finished.isSet = true })
        viewModel.skipTour()
        #expect(setup.isCompleted)
        #expect(setup.savedMode == nil)
        #expect(finished.isSet)
        await viewModel.start()
        #expect(!viewModel.isReady)
    }

    @Test func theReplayNeverTouchesTheAppearance() async throws {
        let appearanceStore = InMemoryAppearanceStore(.light)
        let appearance = AppearanceController(store: appearanceStore, applier: RecordingAppearanceApplier())
        let (viewModel, _) = await conversation(at: .final)
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "desktop" }))
        #expect(viewModel.isFinished)
        #expect(appearance.preference == .light)
        #expect(appearanceStore.stored == .light)
    }
}
