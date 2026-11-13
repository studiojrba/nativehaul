import Foundation
@testable import nativehaul

/// Runs a fresh onboarding conversation straight to a beat's question, answering with the first of the usual ids.
@MainActor
enum OnboardingConversation {
    /// Answers tried, in order of preference, at each beat on the way.
    static let path = ["start", "later", "next", "default", "skip"]

    /// A conversation at `beat` over a mock setup.
    static func at(
        _ beat: OnboardingBeat,
        facts: OnboardingFacts = OnboardingFacts(),
        panel: MockFilePanel = MockFilePanel(),
        finished: FinishFlag = FinishFlag()
    ) async -> (OnboardingChatViewModel, MockOnboardingSetup) {
        let setup = MockOnboardingSetup(facts: facts)
        let viewModel = OnboardingChatViewModel(
            setup: setup,
            panel: panel,
            sleep: { _ in },
            onFinish: { finished.isSet = true }
        )
        await viewModel.start()
        var guardrail = OnboardingBeat.allCases.count * 2
        while viewModel.beat != beat, guardrail > 0 {
            guardrail -= 1
            guard let action = path.lazy.compactMap({ id in viewModel.actions.first { $0.id == id } }).first
            else { break }
            await viewModel.choose(action)
        }
        return (viewModel, setup)
    }

    /// Everything nativehaul said.
    static func said(_ viewModel: OnboardingChatViewModel) -> [String] {
        viewModel.typist.messages.filter { $0.sender == .app }.map(\.text)
    }
}
