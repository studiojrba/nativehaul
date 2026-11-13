import SwiftUI

/// One layer of a CSS `box-shadow`, converted for SwiftUI's `.shadow` (ADR 0054).
///
/// CSS blur is roughly twice SwiftUI's radius, and SwiftUI has no spread, so a negative spread (the design's
/// "tucked-in" warm shadows) is folded into a smaller radius: `radius = max(0, (blur + spread) / 2)`.
struct ShadowLayer: Sendable, Hashable {
    /// Shadow colour (alpha included).
    let color: RGBA
    /// SwiftUI blur radius.
    let radius: CGFloat
    /// Horizontal offset.
    let x: CGFloat
    /// Vertical offset.
    let y: CGFloat

    private static let blurToRadius: CGFloat = 2

    /// No shadow (keeps modifier chains stable when a shadow switches off).
    static let none = ShadowLayer(y: 0, blur: 0, color: RGBA(red: 0, green: 0, blue: 0, alpha: 0))

    /// Converts a CSS `x y blur spread color` layer.
    init(x: CGFloat = 0, y: CGFloat, blur: CGFloat, spread: CGFloat = 0, color: RGBA) {
        self.color = color
        radius = max(0, (blur + spread) / Self.blurToRadius)
        self.x = x
        self.y = y
    }
}

extension View {
    /// Applies one shadow layer.
    func shadow(_ layer: ShadowLayer) -> some View {
        shadow(color: layer.color.color, radius: layer.radius, x: layer.x, y: layer.y)
    }

    /// Applies a two-layer shadow, inner layer first.
    func shadow(_ pair: ShadowPair) -> some View {
        shadow(pair.inner).shadow(pair.outer)
    }
}
