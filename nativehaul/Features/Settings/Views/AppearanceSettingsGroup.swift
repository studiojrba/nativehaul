import SwiftUI

/// Settings → Appearance (spec §3.5): the Light/Dark pill, applied to every screen straight away and remembered.
struct AppearanceSettingsGroup: View {
    /// The app's appearance.
    @Bindable var controller: AppearanceController

    var body: some View {
        SettingsGroup(
            symbolName: "circle.lefthalf.filled",
            tint: .cream,
            title: "Appearance",
            note: "Daylight or evening. Same shelf either way."
        ) {
            SettingsRow(label: "Look", sub: "Changes every screen straight away, and stays that way.") {
                SegmentedPill(
                    options: AppearancePreference.allCases,
                    selection: $controller.preference,
                    title: \.title,
                    symbol: { $0.symbolName }
                )
            }
        }
    }
}

#Preview {
    AppearancePreviewPair {
        AppearanceSettingsGroup(controller: .preview).padding(DesignTokens.Spacing.xl)
    }
}
