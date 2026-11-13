import SwiftUI

/// A drawn cover's four colours (make-export-nov13 `data.ts` palettes): the deep background, the motif's mid tone, its
/// light highlights and the title ink. Each game gets one from the bank by a stable hash of its title, so its cover
/// never changes between launches. Drawn covers are nativehaul's own art (J.R's call: keep the drawn covers); official
/// box art is never bundled or downloaded.
struct CoverPalette: Equatable, Sendable {
    /// Background.
    let deep: RGBA
    /// Motif.
    let mid: RGBA
    /// Highlights.
    let light: RGBA
    /// Title text.
    let ink: RGBA

    // Palette data is token source (Make's 18 palettes, 1:1), so the magic-number rule is off here.
    // swiftlint:disable no_magic_numbers
    /// The bank, from Make's games.
    static let bank: [CoverPalette] = [
        CoverPalette(0x1F3A4A, 0xE8794B, 0xF7C9A3, 0xFFF6EC),
        CoverPalette(0xC8332D, 0xF4B63F, 0xFDE6A6, 0xFFFAF0),
        CoverPalette(0x2C5A4C, 0x8FC2A4, 0xE4F1E2, 0xFBFFF8),
        CoverPalette(0x5B1A26, 0xE05A3D, 0xF6C3A8, 0xFFF2EA),
        CoverPalette(0x2F3566, 0xE8A65A, 0xF5DDB0, 0xFFFAF0),
        CoverPalette(0x2B4F7A, 0xF2A07B, 0xFDE2C8, 0xFFF8EF),
        CoverPalette(0x3B2A63, 0xE86A8A, 0xF8CDD6, 0xFFF5F7),
        CoverPalette(0x26334A, 0x9BB3CF, 0xE2EAF3, 0xF7FBFF),
        CoverPalette(0x3D6A3A, 0xF0C45A, 0xFBEFC4, 0xFFFCEF),
        CoverPalette(0x2E7A73, 0xA7DCC8, 0xE9F6EF, 0xF6FFFB),
        CoverPalette(0xB8322E, 0x5A8FD6, 0xD9E6F7, 0xFFFAF5),
        CoverPalette(0x3A2B3A, 0xE8823C, 0xF7D2AD, 0xFFF6EC),
        CoverPalette(0x3F6A52, 0xF3EFE2, 0xFBF7EC, 0x243A2E),
        CoverPalette(0x2F5A6E, 0xF19A52, 0xFDE1C1, 0xFFFAF2),
        CoverPalette(0x3C6D8C, 0xF4B7A0, 0xFDE7DC, 0xFFFAF6),
        CoverPalette(0xD9577A, 0xF7B8C8, 0xFDE6EC, 0xFFFAFC),
        CoverPalette(0x3A2F8A, 0xE4F25A, 0xF4F8C8, 0xFBFFE8),
        CoverPalette(0x4A2236, 0xE3485C, 0xF7C6C8, 0xFFF4F2),
    ]
    // swiftlint:enable no_magic_numbers

    private init(_ deep: UInt32, _ mid: UInt32, _ light: UInt32, _ ink: UInt32) {
        self.deep = RGBA(hex: deep)
        self.mid = RGBA(hex: mid)
        self.light = RGBA(hex: light)
        self.ink = RGBA(hex: ink)
    }

    /// The palette for `title` (stable across launches).
    static func forTitle(_ title: String) -> CoverPalette {
        bank[Int(CoverSeed.hash(title) % UInt64(bank.count))]
    }
}
