import SwiftUI

/// Play, the signature surface (ADR 0037): the app's one saturated gradient, in a capsule. Pressing dims it slightly;
/// nothing else about it moves.
struct PlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Capsule().fill(Theme.playGradient))
            .opacity(configuration.isPressed ? DesignTokens.Opacity.overlay : DesignTokens.Opacity.full)
            .contentShape(Capsule())
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
