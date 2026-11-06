import SwiftUI

/// The first-run walkthrough. Every screen can be left: "Set up later" on the first, Back/Continue after that.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel
    @Environment(AppEnvironment.self) private var environment

    /// Creates the walkthrough.
    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.none) {
            ScrollView {
                content
                    .padding(DesignTokens.Spacing.xxl)
                    .frame(maxWidth: DesignTokens.Layout.setupMaxWidth, alignment: .leading)
                    .frame(maxWidth: .infinity)
            }
            Divider()
            OnboardingFooter(viewModel: viewModel)
                .padding(DesignTokens.Spacing.lg)
        }
        .frame(minWidth: DesignTokens.Layout.setupMaxWidth, minHeight: DesignTokens.Layout.windowMinHeight)
    }

    @ViewBuilder private var content: some View {
        switch viewModel.step {
        case .welcome: OnboardingWelcomeView()
        case .checklist: OnboardingChecklistView(viewModel: viewModel)
        case let .module(module): OnboardingModuleView(module: module, progress: viewModel.moduleProgress)
        case .done: OnboardingDoneView(outcomes: viewModel.outcomes)
        }
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(store: InMemoryOnboardingStore(), status: FixedOnboardingStatus()))
        .environment(AppEnvironment.preview)
}
