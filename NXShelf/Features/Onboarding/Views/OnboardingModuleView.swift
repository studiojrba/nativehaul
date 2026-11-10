import SwiftUI

/// One checked module: its existing flow, reused as-is.
struct OnboardingModuleView: View {
    /// The module.
    let module: OnboardingModule
    /// "Step n of m".
    let progress: (index: Int, count: Int)?
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            if let progress {
                Text("Step \(progress.index) of \(progress.count)")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
            Label(module.title, systemImage: module.symbolName).font(DesignTokens.Typography.display)
            Text(module.subtitle).foregroundStyle(Theme.secondaryText)
            flow
        }
        .id(module)
    }

    @ViewBuilder private var flow: some View {
        switch module {
        case .findGames:
            GameFoldersSettingsView(viewModel: environment.makeGameFoldersViewModel())
                .frame(minHeight: DesignTokens.Layout.logMinHeight)
        case .switchPorts:
            TrackingSettingsView(viewModel: environment.makeTrackingSettingsViewModel())
                .frame(minHeight: DesignTokens.Layout.logMinHeight)
        case .emulators:
            Text("Add your ROM folders in “Find your games” — NX Shelf sorts ROMs by system on its own.")
                .foregroundStyle(Theme.secondaryText)
            EmulatorSettingsView(viewModel: environment.makeEmulatorSettingsViewModel())
                .frame(minHeight: DesignTokens.Layout.logMinHeight)
        }
    }
}

#Preview {
    OnboardingModuleView(module: .emulators, progress: (2, 3))
        .environment(AppEnvironment.preview)
        .padding(DesignTokens.Spacing.xl)
}
