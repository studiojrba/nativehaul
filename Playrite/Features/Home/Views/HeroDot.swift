import SwiftUI

/// A hero navigation dot: filled for the game showing, faint for the others.
struct HeroDot: View {
    /// Whether this dot's game is showing.
    let isCurrent: Bool

    var body: some View {
        Circle()
            .fill(Theme.onArtwork.opacity(isCurrent ? DesignTokens.Opacity.full : DesignTokens.Opacity.disabled))
            .frame(width: DesignTokens.Home.dotSize, height: DesignTokens.Home.dotSize)
            .contentShape(Circle())
    }
}

#Preview {
    HStack {
        HeroDot(isCurrent: true)
        HeroDot(isCurrent: false)
    }
    .padding(DesignTokens.Spacing.lg)
    .background(Theme.artworkScrim)
}
