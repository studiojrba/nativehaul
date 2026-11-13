// The neutral fallback's hex values are token source, so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// A game's colours, derived from its artwork (spec §2.5, §6): the only colour in the UI beyond the locked palette.
struct GamePalette: Sendable, Hashable {
    /// The darkest tone (case spine, deep shadows).
    let deep: RGBA
    /// The dominant colour.
    let mid: RGBA
    /// A light tint of the dominant colour (daylight glows).
    let light: RGBA
    /// The soft full-area daylight tint behind the game.
    let wash: RGBA
    /// Text over ``deep`` artwork.
    let ink: RGBA

    /// The palette used when a game has no artwork: the house paper and cream, so a bare game still sits warmly.
    static let neutral = GamePalette(
        deep: RGBA(hex: 0x3A3029),
        mid: RGBA(hex: 0xC9A27A),
        light: RGBA(hex: 0xF3E3C8),
        wash: RGBA(hex: 0xF6EFE2),
        ink: RGBA(hex: 0xFFF8EE)
    )
}

// swiftlint:enable no_magic_numbers
