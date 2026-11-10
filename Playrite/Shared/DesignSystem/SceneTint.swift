import AppKit
import SwiftUI

/// The per-scene pastel tint (ADR 0040, the way Kriss washes a whole scene in one soft colour). A screen names the
/// art it is about; the shell washes the whole window, sidebar included, in a pastel of that art's colour, fading into
/// the cream canvas. The dial sets how much colour comes through (``EnergyLevel/pastelSaturation``).
enum SceneTint {
    /// The pastel for art tinted `color` at `saturation`.
    static func pastel(from color: NSColor, saturation: CGFloat) -> NSColor {
        let rgb = color.usingColorSpace(.sRGB) ?? color
        var hue: CGFloat = 0
        var oldSaturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        rgb.getHue(&hue, saturation: &oldSaturation, brightness: &brightness, alpha: &alpha)
        return NSColor(
            hue: hue,
            saturation: min(oldSaturation, saturation),
            brightness: DesignTokens.Light.pastelBrightness,
            alpha: 1
        )
    }
}
