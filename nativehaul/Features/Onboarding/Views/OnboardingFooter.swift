import SwiftUI

/// Back / Continue, plus "Set up later" on the first screen.
struct OnboardingFooter: View {
    /// Walkthrough state.
    let viewModel: OnboardingViewModel

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            if viewModel.step == .welcome {
                Button("Set up later") { viewModel.skipAll() }
            } else {
                Button("Back") { viewModel.back() }
            }
            Spacer()
            Button(continueTitle) { viewModel.next() }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
        }
    }

    private var continueTitle: String {
        switch viewModel.step {
        case .welcome: "Get started"
        case .checklist: viewModel.plannedModules.isEmpty ? "Skip to the end" : "Continue"
        case .module: "Continue"
        case .done: "Open my library"
        }
    }
}

#Preview {
    OnboardingFooter(viewModel: OnboardingViewModel(store: InMemoryOnboardingStore(), status: FixedOnboardingStatus()))
        .padding(DesignTokens.Spacing.lg)
}
