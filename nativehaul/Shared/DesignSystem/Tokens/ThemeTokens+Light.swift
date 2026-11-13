// This file *is* token source: its hex values are the named constants (spec §2), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ThemeTokens {
    /// Daylight: paper, charcoal ink, cream lamplight, one ember accent (spec §2.1–2.3).
    static let light = ThemeTokens(
        paper: RGBA(hex: 0xFBF7EF),
        paper2: RGBA(hex: 0xF6EFE2),
        surface: RGBA(hex: 0xFFFFFF),
        knob: RGBA(hex: 0xFFFFFF),
        ink: RGBA(hex: 0x242328),
        inkSoft: RGBA(hex: 0x5C5850),
        inkMute: RGBA(hex: 0x8F897D),
        cream: RGBA(hex: 0xFEE7C0),
        cream2: RGBA(hex: 0xFFF3DD),
        lamp: Palette.lamp,
        accent: Palette.ember,
        onAccent: RGBA(hex: 0xFFFFFF),
        hair: RGBA(red8: 36, green8: 35, blue8: 40, alpha: 0.10),
        hairStrong: RGBA(red8: 36, green8: 35, blue8: 40, alpha: 0.20),
        bezel: RGBA(hex: 0x242328),
        floor: RGBA(red8: 107, green8: 68, blue8: 21, alpha: 0.25),
        ok: RGBA(hex: 0x2F6B4A),
        warning: RGBA(hex: 0xA86E12),
        danger: RGBA(hex: 0xB3311F),
        selection: RGBA(hex: 0xFEE7C0),
        frostFill: RGBA(red8: 255, green8: 252, blue8: 246, alpha: 0.62),
        frostEdge: RGBA(red8: 255, green8: 252, blue8: 246, alpha: 0),
        washes: Washes(
            sky: RGBA(hex: 0xDDE9F4),
            blush: RGBA(hex: 0xF9DFD8),
            mint: RGBA(hex: 0xDCEFE2),
            butter: RGBA(hex: 0xFBF0C6),
            cream: RGBA(hex: 0xFEE7C0),
            peach: RGBA(hex: 0xF6DCCB),
            lilac: RGBA(hex: 0xE9E4F6)
        )
    )
}

// swiftlint:enable no_magic_numbers
