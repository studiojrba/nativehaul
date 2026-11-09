import SwiftUI

/// The Home page's ambient colour (ADR 0035): the featured game's art colour washed full-bleed into the page behind
/// the hero, fading out further down. A background only, so it never changes layout; it crossfades with the hero.
struct HomeAmbientBackground: View {
    /// The featured game's banner art.
    let imagePath: String?

    var body: some View {
        ZStack(alignment: .top) {
            Theme.canvas
            if let tint = ArtworkTint.color(forImageAt: imagePath) {
                LinearGradient(
                    colors: [tint.opacity(DesignTokens.Home.ambientOpacity), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: DesignTokens.Home.ambientHeight)
                .blur(radius: DesignTokens.Home.ambientBlur)
                .id(imagePath)
                .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    HomeAmbientBackground(imagePath: nil)
}
