import SwiftUI

/// Settings until its 0.1.0 redesign lands (a later phase): the existing settings tabs, in the page under the
/// "Settings" eyebrow and "The back room", over a sky and butter wash.
struct SettingsPage: View {
    /// App dependencies.
    let environment: AppEnvironment

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: ShellLayout.SectionHead.titleTop) {
                Eyebrow("Settings")
                DisplayHeadline(lead: "The back room", size: TypeStyle.DisplaySize.page)
            }
            .riseIn()
            SettingsView(environment: environment)
                .background(
                    RoundedRectangle(cornerRadius: KitMetrics.Radius.panel, style: .continuous)
                        .fill(Theme.surface.opacity(KitMetrics.PillButton.surfaceOpacity))
                )
                .elevation(.small)
        }
        .padding(.leading, ShellLayout.Chrome.islandClearance)
        .padding(.top, ShellLayout.Chrome.topBarClearance + DesignTokens.Spacing.lg)
        .padding([.trailing, .bottom], ShellLayout.Content.trailingInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(alignment: .top) {
            WashBackground(slots: [.sky, .butter])
                .frame(height: ShellLayout.Library.washHeight)
        }
    }
}

#Preview {
    SettingsPage(environment: .preview)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
