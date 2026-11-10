import AppKit

// This file *is* the colour token source: its hex values and channel shifts are the named constants every view uses
// through ``Theme``, so the magic-number rule is off here and nowhere else.
// swiftlint:disable no_magic_numbers

/// Raw colour values behind ``Theme``, as 24-bit RGB. **One appearance, light** (J.R, 2026-11-09 20:00, ADR 0040):
/// dark appearance support is removed, not just un-defaulted.
///
/// The feel follows Kriss: airy, bright but not sterile, fun but cozy. Neutrals are warm cream and off-white, never
/// blue-grey and never clinical white; text is a warm near-black. Colour comes from game art, washed in as a soft
/// pastel per scene (``SceneTint``), plus the one accent — "Fetch orange" — used sparingly.
enum Palette {
    static let canvas: UInt32 = 0xFBF6EE
    static let sidebar: UInt32 = 0xF7F0E5
    static let surface: UInt32 = 0xFFFCF7
    static let surfaceRaised: UInt32 = 0xF2EADF
    static let hairline: UInt32 = 0xEADFD0
    static let hairlineStrong: UInt32 = 0xD8CAB6
    static let textPrimary: UInt32 = 0x2B231D
    static let textSecondary: UInt32 = 0x76695C
    static let textTertiary: UInt32 = 0xA39484
    /// Fetch orange: a warm, slightly playful red-orange.
    static let accent: UInt32 = 0xF0531C
    /// The far end of Play's gradient, the one saturated gradient in the app (ADR 0037).
    static let accentDeep: UInt32 = 0xE8285A
    /// Text and icons on the accent.
    static let onAccent: UInt32 = 0xFFFBF5
    static let success: UInt32 = 0x3D8A62
    static let warning: UInt32 = 0xB0791C
    static let danger: UInt32 = 0xC4473D
    static let muted: UInt32 = 0x8C7F71
    /// Soft shadows replace hard borders: a warm brown, never grey-black.
    static let shadow: UInt32 = 0x6B4A2B
    /// Title printed on a game case's spine (ADR 0039): warm off-white on the case colour.
    static let caseSpineText: UInt32 = 0xFBF6EE

    /// The colour for a value.
    static func color(_ value: UInt32) -> NSColor {
        let channel: (UInt32) -> CGFloat = { CGFloat((value >> $0) & 0xFF) / 0xFF }
        return NSColor(srgbRed: channel(16), green: channel(8), blue: channel(0), alpha: 1)
    }
}

// swiftlint:enable no_magic_numbers
