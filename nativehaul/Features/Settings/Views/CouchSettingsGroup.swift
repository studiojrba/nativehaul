import SwiftUI

/// Settings → Couch mode (spec §3.5): the mode nativehaul opens in, and controller rumble. Both persist; couch mode
/// reads them when it starts.
struct CouchSettingsGroup: View {
    /// The mode preferences.
    @Bindable var viewModel: CouchSettingsViewModel

    var body: some View {
        SettingsGroup(
            symbolName: "tv",
            tint: .sky,
            title: "Couch mode",
            note: "For the sofa and the big screen."
        ) {
            SettingsRow(label: "Open in", sub: "What nativehaul shows when it starts.") {
                SegmentedPill(
                    options: [AppMode.desktop, .couch],
                    selection: $viewModel.defaultMode,
                    title: { $0 == .desktop ? "Desktop" : "Couch" },
                    symbol: { $0 == .desktop ? "desktopcomputer" : "tv" }
                )
            }
            SettingsRow(label: "Controller rumble", sub: "A little buzz when you pick something.") {
                ToggleSwitchTrack(isOn: $viewModel.isRumbleEnabled)
                    .accessibilityLabel("Controller rumble")
            }
        }
    }
}

#Preview {
    AppearancePreviewPair {
        CouchSettingsGroup(viewModel: CouchSettingsViewModel(store: InMemoryModePreferenceStore()))
            .padding(DesignTokens.Spacing.xl)
    }
}
