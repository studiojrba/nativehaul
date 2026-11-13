import AppKit
import SwiftUI

/// A concrete sRGB colour value with alpha: the raw form of every token (ADR 0054).
///
/// Tokens are stored as values rather than `Color`s so they can be mixed (``mixed(with:by:)``), compared in tests and
/// resolved per appearance. Channels are 0…1.
struct RGBA: Sendable, Hashable {
    /// Red channel, 0…1.
    let red: Double
    /// Green channel, 0…1.
    let green: Double
    /// Blue channel, 0…1.
    let blue: Double
    /// Alpha, 0…1.
    let alpha: Double

    private static let channelMax: Double = 255
    private static let byteMask: UInt32 = 0xFF
    private static let redShift: UInt32 = 16
    private static let greenShift: UInt32 = 8

    /// Creates a colour from channels in 0…1.
    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// Creates a colour from a 24-bit `0xRRGGBB` value, as written in the spec (`#FBF7EF` → `0xFBF7EF`).
    init(hex: UInt32, alpha: Double = 1) {
        let channel: (UInt32) -> Double = { Double((hex >> $0) & Self.byteMask) / Self.channelMax }
        self.init(red: channel(Self.redShift), green: channel(Self.greenShift), blue: channel(0), alpha: alpha)
    }

    /// Creates a colour from 0…255 channels, as in CSS `rgba(36, 35, 40, 0.10)`.
    init(red8: Int, green8: Int, blue8: Int, alpha: Double = 1) {
        self.init(
            red: Double(red8) / Self.channelMax,
            green: Double(green8) / Self.channelMax,
            blue: Double(blue8) / Self.channelMax,
            alpha: alpha
        )
    }

    /// The same colour at another alpha.
    func opacity(_ alpha: Double) -> RGBA {
        RGBA(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// The design's `mix(a, b, t)`: a linear sRGB lerp from `self` (t = 0) to `other` (t = 1), each channel rounded to
    /// 8 bits exactly as the reference code does. Alpha lerps too (both are usually opaque).
    func mixed(with other: RGBA, by fraction: Double) -> RGBA {
        let lerp: (Double, Double) -> Double = { from, to in
            (from * Self.channelMax + (to - from) * Self.channelMax * fraction).rounded() / Self.channelMax
        }
        return RGBA(
            red: lerp(red, other.red),
            green: lerp(green, other.green),
            blue: lerp(blue, other.blue),
            alpha: alpha + (other.alpha - alpha) * fraction
        )
    }

    /// Relative luminance (Rec. 709 weights on the gamma-encoded channels; a fast perceptual ordering, not WCAG).
    var luminance: Double {
        Luma.red * red + Luma.green * green + Luma.blue * blue
    }

    /// Chroma: the spread between the strongest and weakest channel (what reads as colour).
    var chroma: Double {
        max(red, green, blue) - min(red, green, blue)
    }

    /// The 24-bit `0xRRGGBB` value, alpha dropped.
    var hex: UInt32 {
        let byte: (Double) -> UInt32 = { UInt32((min(max($0, 0), 1) * Self.channelMax).rounded()) }
        return byte(red) << Self.redShift | byte(green) << Self.greenShift | byte(blue)
    }

    /// The colour for SwiftUI.
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    /// The colour for AppKit.
    var nsColor: NSColor {
        NSColor(srgbRed: red, green: green, blue: blue, alpha: alpha)
    }

    /// Luminance weights.
    private enum Luma {
        static let red = 0.2126
        static let green = 0.7152
        static let blue = 0.0722
    }
}
