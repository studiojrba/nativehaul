import SwiftUI

/// Settings → Behind the scenes (ADR 0057): nativehaul's own updates right here, and every detailed setting from before
/// 0.1.0 one click away in a sheet, so nothing was lost in the redesign.
struct BehindTheScenesGroup: View {
    /// App dependencies.
    let environment: AppEnvironment
    /// nativehaul's own updates.
    @Bindable var updates: UpdatesSettingsViewModel
    @State private var presented: SettingsSheet?

    var body: some View {
        SettingsGroup(
            symbolName: "wrench.and.screwdriver",
            tint: .lilac,
            title: "Behind the scenes",
            note: "Everything else, for the curious. The defaults are fine."
        ) {
            SettingsRow(
                label: "nativehaul updates",
                sub: "Checks once a day and asks before installing. Sends nothing about you."
            ) {
                HStack(spacing: ShellLayout.Settings.controlGap) {
                    Button("Check for Updates…") { updates.appUpdater.checkForUpdates() }
                        .buttonStyle(CreamPillButtonStyle())
                        .disabled(!updates.appUpdater.canCheckForUpdates)
                    ToggleSwitchTrack(isOn: $updates.checksForAppUpdates)
                        .accessibilityLabel("Check for nativehaul updates automatically")
                }
            }
            ForEach(SettingsSheet.allCases) { sheet in
                SettingsRow(label: sheet.title, sub: sheet.subtitle) {
                    Button("Open…") { presented = sheet }.buttonStyle(CreamPillButtonStyle())
                }
            }
        }
        .sheet(item: $presented) { SettingsSheetView(sheet: $0, environment: environment) }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    AppearancePreviewPair {
        BehindTheScenesGroup(environment: environment, updates: environment.makeUpdatesSettingsViewModel())
            .padding(DesignTokens.Spacing.xl)
    }
}
