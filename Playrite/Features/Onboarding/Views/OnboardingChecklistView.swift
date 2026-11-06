import SwiftUI

/// "What do you want to set up now?" — every item optional; only checked items get a step.
struct OnboardingChecklistView: View {
    /// Walkthrough state.
    let viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("What do you want to set up now?").font(DesignTokens.Typography.largeTitle)
            Text(OnboardingViewModel.reassurance).foregroundStyle(Theme.secondaryText)
            ForEach(viewModel.modules) { module in
                Toggle(isOn: Binding(get: { viewModel.isSelected(module) }, set: { _ in viewModel.toggle(module) })) {
                    Label {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                            Text(module.title).font(DesignTokens.Typography.headline)
                            Text(module.subtitle).foregroundStyle(Theme.secondaryText)
                        }
                    } icon: {
                        Image(systemName: module.symbolName)
                    }
                }
                .toggleStyle(.checkbox)
            }
            if !viewModel.modules.contains(.emulators) {
                Label("Emulators — coming soon", systemImage: OnboardingModule.emulators.symbolName)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

#Preview {
    OnboardingChecklistView(viewModel: OnboardingViewModel(
        store: InMemoryOnboardingStore(),
        status: FixedOnboardingStatus()
    ))
    .padding(DesignTokens.Spacing.xl)
}
