import SwiftUI

/// Play, the signature surface (ADR 0037, ADR 0054): the ember fill in a capsule — a soft accent shadow by day, the
/// ember glow at night — with the house press feedback.
struct PlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(EmberFill(shape: Capsule()))
            .contentShape(Capsule())
            .pressFeedback(isPressed: configuration.isPressed)
    }
}

#Preview {
    Button {} label: {
        Label("Play", systemImage: "play.fill")
            .font(DesignTokens.Typography.launch)
            .foregroundStyle(Theme.onAccent)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.Details.launchButtonHeight)
    }
    .buttonStyle(PlayButtonStyle())
    .padding(DesignTokens.Spacing.xl)
}
