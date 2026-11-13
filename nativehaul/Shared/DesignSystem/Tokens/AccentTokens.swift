import SwiftUI

// Accent treatments are token source (spec §2.6), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// Accent treatments (spec §2.6): the ember primary button, the small-element glow and the keyboard focus ring.
/// A soft shadow by day, an ember glow by night.
enum AccentTokens {
    /// Ember by day: one soft accent shadow.
    static let emberDayShadow = ShadowLayer(y: 14, blur: 30, spread: -10, color: Palette.ember.opacity(0.60))
    /// Ember by night: the glow and the drop shadow.
    static let emberNightShadows = ShadowPair(
        inner: ShadowLayer(y: 0, blur: 26, spread: -4, color: Palette.ember.opacity(0.70)),
        outer: ShadowLayer(y: 14, blur: 36, spread: -14, color: Palette.ember.opacity(0.70))
    )
    /// Ember by night: the radial gradient stops (`#FF8150 → #FB4417 (52%) → #D63810`).
    static let emberNightStops: [Gradient.Stop] = [
        .init(color: RGBA(hex: 0xFF8150).color, location: 0),
        .init(color: Palette.ember.color, location: 0.52),
        .init(color: RGBA(hex: 0xD63810).color, location: 1),
    ]
    /// The gradient's centre (`at 30% 15%`).
    static let emberNightCenter = UnitPoint(x: 0.30, y: 0.15)
    /// The gradient's reach, as a multiple of the button's longer side (`130% 160%`, averaged).
    static let emberNightReach: CGFloat = 1.45
    /// Ember by night: the inset top light.
    static let emberInnerLight = RGBA(red8: 255, green8: 196, blue8: 160, alpha: 0.35)
    /// The far end of the daylight Play gradient (a deeper ember).
    static let emberDeep = RGBA(hex: 0xD63810)

    /// `glow` for small active elements (dots, switches, the current progress segment), dark only.
    static let smallGlow = ShadowLayer(y: 0, blur: 14, spread: -1, color: Palette.ember.opacity(0.65))
    /// The nav island's active-button ember halo, dark only.
    static let navHalo = ShadowLayer(y: 0, blur: 22, spread: -8, color: Palette.ember.opacity(0.70))
    /// Couch-focused chevron glow.
    static let chevronFocusGlow = ShadowLayer(y: 0, blur: 10, color: Palette.ember.opacity(0.55))

    /// Focus ring width.
    static let focusRingWidth: CGFloat = 2
    /// Gap between the element and its focus ring.
    static let focusRingOffset: CGFloat = 3
    /// The focus ring's glow by night.
    static let focusNightGlow = ShadowLayer(y: 0, blur: 22, spread: -2, color: Palette.ember.opacity(0.55))

    /// Artwork at night (`saturate(1.12) contrast(1.05) brightness(1.03)`).
    enum NightArtwork {
        /// Saturation multiplier.
        static let saturation: Double = 1.12
        /// Contrast multiplier.
        static let contrast: Double = 1.05
        /// SwiftUI brightness is additive; +0.02 approximates CSS's ×1.03 on mid-tones.
        static let brightness: Double = 0.02
    }
}

// swiftlint:enable no_magic_numbers
