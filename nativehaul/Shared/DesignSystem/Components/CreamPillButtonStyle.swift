import SwiftUI

/// The quiet "Change…" pill (spec §3.5 path rows): `cream` at 80%, 13pt, with press feedback and the hand cursor.
struct CreamPillButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typeface.sans(TypeStyle.Size.small))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, ShellLayout.Settings.changeHorizontal)
            .padding(.vertical, ShellLayout.Settings.changeVertical)
            .background(Capsule().fill(Theme.cream.opacity(ShellLayout.Settings.changeOpacity)))
            .contentShape(Capsule())
            .opacity(isEnabled ? 1 : DesignTokens.Opacity.disabled)
            .pressFeedback(isPressed: configuration.isPressed)
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.md) {
            Button("Change…") {}
            Button("Add…") {}
        }
        .buttonStyle(CreamPillButtonStyle())
        .padding(DesignTokens.Spacing.xl)
    }
}
