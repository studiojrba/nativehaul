import SwiftUI

/// The detail hero's ambient wash (ADR 0025): a soft, blurred gradient in the colour sampled from the game's own
/// artwork, behind the hero and fading out below it. Weak by design, so text contrast never suffers; drawn as a
/// background, so it never changes layout.
struct ArtGlowBackground: View {
    /// The artwork the colour is sampled from.
    let imagePath: String?

    var body: some View {
        if let tint = ArtworkTint.color(forImageAt: imagePath) {
            LinearGradient(
                colors: [tint.opacity(DesignTokens.ArtTint.heroGlowOpacity), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.Details.heroHeight * DesignTokens.ArtTint.heroGlowReach)
            .padding(.horizontal, -DesignTokens.ArtTint.heroGlowBlur * DesignTokens.ArtTint.heroGlowSpread)
            .padding(.top, -DesignTokens.Spacing.xl)
            .blur(radius: DesignTokens.ArtTint.heroGlowBlur)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

#Preview {
    ArtGlowBackground(imagePath: nil)
}
