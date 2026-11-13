import SwiftUI

/// Artwork at night (spec §2.6, `.art`): a touch richer, like a screen in a dark room. Unchanged by day.
struct NightArtwork: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        return content
            .saturation(isDark ? AccentTokens.NightArtwork.saturation : 1)
            .contrast(isDark ? AccentTokens.NightArtwork.contrast : 1)
            .brightness(isDark ? AccentTokens.NightArtwork.brightness : 0)
    }
}

extension View {
    /// Applies the night-time artwork adjustment.
    func nightArtwork() -> some View {
        modifier(NightArtwork())
    }
}

#Preview {
    AppearancePreviewPair {
        WashBackground(colors: [Palette.ember, Palette.amber, Palette.readyDot])
            .frame(width: DesignTokens.Cover.detailWidth, height: DesignTokens.Cover.detailWidth)
            .nightArtwork()
    }
}
