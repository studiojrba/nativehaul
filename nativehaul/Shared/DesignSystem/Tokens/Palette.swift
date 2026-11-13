// This file *is* token source: its hex values are the named constants (spec §1.6, §2), so the magic-number rule is off.
// swiftlint:disable no_magic_numbers

/// The locked brand palette and the constants that never change with the appearance (spec §1.6, §2.1, §2.5, §2.6).
///
/// Colour beyond these comes from game artwork (``GamePalette``), never from UI chrome.
enum Palette {
    /// Charcoal, the palette's ink.
    static let charcoal = RGBA(hex: 0x242328)
    /// Cream, the palette's lamplight.
    static let lamp = RGBA(hex: 0xFEE7C0)
    /// Ember, the one accent.
    static let ember = RGBA(hex: 0xFB4417)
    /// The evening tone dark washes settle toward (`EVENING`, spec §2.5).
    static let evening = RGBA(hex: 0x1D1815)
    /// The amber warmth mixed into dark washes (`AMBER`, spec §2.5).
    static let amber = RGBA(hex: 0xC98A4A)
    /// Pure white: daylight "air" in washes (``GameTones/lift(_:)``) and palette maths.
    static let white = RGBA(hex: 0xFFFFFF)
    /// Decorative traffic-light dots in the top bar (constant in both modes).
    static let trafficRed = RGBA(hex: 0xFF6159)
    /// Decorative traffic-light dots in the top bar (constant in both modes).
    static let trafficYellow = RGBA(hex: 0xFFBD2E)
    /// Decorative traffic-light dots in the top bar (constant in both modes).
    static let trafficGreen = RGBA(hex: 0x28C941)
    /// The build-status "ready" dot on Detail (constant in both modes).
    static let readyDot = RGBA(hex: 0x4CAF7A)
    /// Warm near-white text over artwork behind a dark scrim (light in both modes, never pure white on black).
    static let onArtwork = RGBA(hex: 0xFFF8EE)
    /// Behind a trailer: the evening bezel, never pure black.
    static let mediaBackdrop = RGBA(hex: 0x16120F)
}

// swiftlint:enable no_magic_numbers
