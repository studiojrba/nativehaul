import SwiftUI

/// One "Behind the scenes" sheet: the detailed settings form, with Done.
struct SettingsSheetView: View {
    /// Which settings.
    let sheet: SettingsSheet
    /// App dependencies.
    let environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            content
            HStack {
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.defaultAction)
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .frame(minWidth: ShellLayout.Settings.sheetMinWidth, minHeight: ShellLayout.Settings.sheetMinHeight)
        .background(Theme.paper)
    }

    @ViewBuilder private var content: some View {
        switch sheet {
        case .updates:
            UpdatesSettingsView(viewModel: environment.makeUpdatesSettingsViewModel())
        case .emulators:
            EmulatorSettingsView(viewModel: environment.makeEmulatorSettingsViewModel())
        case .tracking:
            TrackingSettingsView(viewModel: environment.makeTrackingSettingsViewModel())
        case .engine:
            NXNativeSettingsView(viewModel: environment.makeNXNativeSettingsViewModel())
        }
    }
}

#Preview {
    SettingsSheetView(sheet: .tracking, environment: .preview)
}
