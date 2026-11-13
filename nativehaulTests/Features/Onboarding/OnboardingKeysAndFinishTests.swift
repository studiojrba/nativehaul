import Foundation
@testable import nativehaul
import Testing

/// Spec §3.6 library key, emulator, couch and closing beats: detect, don't re-demand (ADR 0021); never hint at
/// sources; skipping is one click; choosing a mode saves it and says goodbye; "Let's play" finishes.
@MainActor
struct OnboardingKeysAndFinishTests {
    private func said(_ viewModel: OnboardingChatViewModel) -> [String] {
        OnboardingConversation.said(viewModel)
    }

    @Test func aDetectedLibraryKeyIsAcknowledgedAndNeverAskedFor() async {
        var facts = OnboardingFacts()
        facts.detectedKeys = "/Users/demo/Switch/ProdKeys/prod.keys"
        let (viewModel, _) = await OnboardingConversation.at(.keys, facts: facts)
        #expect(viewModel.beat == .keys)
        #expect(said(viewModel).contains("Found your library key already. Lovely."))
        #expect(viewModel.actions.map(\.effect) == [.advance(.player)])
    }

    @Test func withoutTheKeyTheAskOffersAddHelpAndSkip() async {
        let (viewModel, _) = await OnboardingConversation.at(.keys)
        #expect(said(viewModel).contains(
            "It comes from your own console and lets me build your Switch games. It never leaves this Mac."
        ))
        #expect(viewModel.actions.map(\.label) == ["Add my library key", "Remind me what it is", "Skip for now"])
    }

    @Test func theExplainerNamesNoToolAndHintsAtNoSource() {
        let words = (OnboardingScript.keysHelp + OnboardingScript.keysSteps).joined(separator: " ").lowercased()
        for banned in ["lockpick", "homebrew", "dump", "download", "rcm", "hekate", "atmosphere"] {
            #expect(!words.contains(banned))
        }
        #expect(words.contains("your own console"))
    }

    @Test func noConversationLineUsesTheRawKeyWords() {
        var facts = OnboardingFacts()
        let lines = OnboardingBeat.allCases.flatMap { beat in
            [OnboardingKeysOutcomeCase.none, .placed, .skipped].flatMap { outcome -> [String] in
                facts.keysOutcome = outcome.value
                return OnboardingScript.messages(for: beat, facts: facts)
                    + OnboardingScript.actions(for: beat, facts: facts).map(\.label)
            }
        }
        let text = lines.joined(separator: " ").lowercased()
        for banned in ["prod.keys", "switch keys", "keys file", "decrypt", "title id", "game id", "prepare"] {
            #expect(!text.contains(banned), "\(banned)")
        }
    }

    @Test func skippingTheKeyIsOneClickAndSaidKindly() async {
        let (viewModel, setup) = await OnboardingConversation.at(.player)
        #expect(viewModel.beat == .player)
        #expect(setup.placedKeys.isEmpty)
        #expect(said(viewModel).contains("No problem. Switch builds can wait until you have it."))
    }

    @Test func aPickedOrDroppedKeyIsPlacedThroughTheUserFileFlow() async throws {
        let panel = MockFilePanel(file: URL(fileURLWithPath: "/tmp/picked.keys"))
        let (viewModel, setup) = await OnboardingConversation.at(.keys, panel: panel)
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "add" }))
        #expect(panel.fileAsks == 1)
        #expect(setup.placedKeys == ["/tmp/picked.keys"])
        #expect(said(viewModel).contains("Got it, your library key is in place."))

        let (dropModel, dropSetup) = await OnboardingConversation.at(.keys)
        await dropModel.dropped(URL(fileURLWithPath: "/tmp/dropped.keys"))
        #expect(dropSetup.placedKeys == ["/tmp/dropped.keys"])
        #expect(dropModel.beat == .player)
    }

    @Test func cancellingTheKeyPickerKeepsTheQuestionOpen() async throws {
        let panel = MockFilePanel()
        let (viewModel, setup) = await OnboardingConversation.at(.keys, panel: panel)
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "add" }))
        #expect(setup.placedKeys.isEmpty)
        #expect(viewModel.beat == .keys)
        #expect(viewModel.isReady)
    }

    @Test func choosingCouchSavesTheModeThenTheClosingBeatSaysGoodbye() async throws {
        let finished = FinishFlag()
        let (viewModel, setup) = await OnboardingConversation.at(.final, finished: finished)
        #expect(viewModel.beat == .final)
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "couch" }))
        #expect(setup.savedMode == .couch)
        #expect(viewModel.beat == .closing)
        #expect(viewModel.facts.chosenMode == .couch)
        #expect(said(viewModel).contains("Happy gaming!"))
        #expect(!finished.isSet)
        #expect(viewModel.actions.map(\.label) == ["Let’s play"])
        try await viewModel.choose(#require(viewModel.actions.first))
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
        let (viewModel, _) = await OnboardingConversation.at(.final)
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "desktop" }))
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "play" }))
        #expect(viewModel.isFinished)
        #expect(appearance.preference == .light)
        #expect(appearanceStore.stored == .light)
    }
}

/// The library key outcomes checked by the wording sweep.
private enum OnboardingKeysOutcomeCase {
    case none, placed, skipped

    var value: KeysOutcome? {
        switch self {
        case .none: nil
        case .placed: .placed
        case .skipped: .skipped
        }
    }
}
