// This file *is* token source: its hex values are the named constants (spec §2), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ThemeTokens {
    /// The same room in the evening, not an inversion: warm charcoal, cream as lamplight, the accent as an ember glow
    /// (spec §1.7, §2.1–2.3). No pure black, no blue-grey.
    static let dark = ThemeTokens(
        paper: RGBA(hex: 0x211C19),
        paper2: RGBA(hex: 0x2B241F),
        surface: RGBA(hex: 0x3A3029),
        knob: RGBA(hex: 0xFEE7C0),
        ink: RGBA(hex: 0xFEE7C0),
        inkSoft: RGBA(hex: 0xDCC6A4),
        inkMute: RGBA(hex: 0xA08D75),
        cream: RGBA(hex: 0x4A3B2C),
        cream2: RGBA(hex: 0x3A2F26),
        lamp: Palette.lamp,
        accent: Palette.ember,
        onAccent: RGBA(hex: 0xFFF1DC),
        hair: RGBA(red8: 254, green8: 231, blue8: 192, alpha: 0.12),
        hairStrong: RGBA(red8: 254, green8: 231, blue8: 192, alpha: 0.24),
        bezel: RGBA(hex: 0x16120F),
        floor: RGBA(red8: 10, green8: 6, blue8: 3, alpha: 0.55),
        ok: RGBA(hex: 0xC9DFAE),
        warning: RGBA(hex: 0xE3B062),
        danger: RGBA(hex: 0xF08A74),
        selection: RGBA(red8: 251, green8: 68, blue8: 23, alpha: 0.40),
        frostFill: RGBA(red8: 46, green8: 37, blue8: 31, alpha: 0.62),
        frostEdge: RGBA(red8: 254, green8: 231, blue8: 192, alpha: 0.09),
        washes: Washes(
            sky: RGBA(hex: 0x44362E),
            blush: RGBA(hex: 0x56342A),
            mint: RGBA(hex: 0x403B2D),
            butter: RGBA(hex: 0x584326),
            cream: RGBA(hex: 0x584631),
            peach: RGBA(hex: 0x57392A),
            lilac: RGBA(hex: 0x48362F)
        )
    )
}

// swiftlint:enable no_magic_numbers
