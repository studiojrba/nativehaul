import AppKit

// This file *is* the colour token source: its hex values and channel shifts are the named constants every view uses
// through ``Theme``, so the magic-number rule is off here and nowhere else.
// swiftlint:disable no_magic_numbers

/// Raw colour values behind ``Theme`` (ADR 0025), as 24-bit RGB, one pair per role: dark appearance, then light.
///
/// Structure is neutral (Linear's near-black canvas, one-step surfaces, hairlines instead of shadows, a sidebar
/// dimmer than the canvas). Exactly one saturated pop — ``accent``, "Fetch orange" — carries the personality, in the
/// spirit of the (Not Boring) apps. Status colours are muted so the grid reads calm at arm's length.
enum Palette {
    /// A dark/light pair.
    struct Pair: Sendable {
        let dark: UInt32
        let light: UInt32
    }

    static let canvas = Pair(dark: 0x08090A, light: 0xFCFCFD)
    static let sidebar = Pair(dark: 0x040405, light: 0xF1F2F4)
    static let surface = Pair(dark: 0x101113, light: 0xF5F6F8)
    static let surfaceRaised = Pair(dark: 0x16171B, light: 0xECEDF0)
    static let hairline = Pair(dark: 0x1F2023, light: 0xE2E3E7)
    static let hairlineStrong = Pair(dark: 0x34363B, light: 0xC9CBD1)
    static let textPrimary = Pair(dark: 0xF7F8F8, light: 0x0D0E10)
    static let textSecondary = Pair(dark: 0x8A8F98, light: 0x5C6069)
    static let textTertiary = Pair(dark: 0x62666D, light: 0x8A8F98)
    /// Fetch orange: a saturated, warm, slightly playful red-orange that pops on near-black and on white.
    static let accent = Pair(dark: 0xFF5A1F, light: 0xF24E12)
    /// The far end of Play's gradient, the one saturated gradient in the app (ADR 0037).
    static let accentDeep = Pair(dark: 0xFF2D55, light: 0xE6194B)
    /// Text and icons on the accent (near-black reads bolder and clearer on the orange than white does).
    static let onAccent = Pair(dark: 0x0B0B0C, light: 0x0B0B0C)
    static let success = Pair(dark: 0x5BA37F, light: 0x2F7D58)
    static let warning = Pair(dark: 0xD6A250, light: 0xA86E12)
    static let danger = Pair(dark: 0xE56B6B, light: 0xC23B3B)
    static let muted = Pair(dark: 0x7D8796, light: 0x66707E)
    /// Title printed on a game case's spine (ADR 0039): warm off-white on the case colour.
    static let caseSpineText = Pair(dark: 0xF7F3EC, light: 0xF7F3EC)

    /// A colour that follows the current appearance.
    static func color(_ pair: Pair) -> NSColor {
        NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return rgb(isDark ? pair.dark : pair.light)
        }
    }

    private static func rgb(_ value: UInt32) -> NSColor {
        let channel: (UInt32) -> CGFloat = { CGFloat((value >> $0) & 0xFF) / 0xFF }
        return NSColor(srgbRed: channel(16), green: channel(8), blue: channel(0), alpha: 1)
    }
}

// swiftlint:enable no_magic_numbers
