import SwiftUI

// This file is token source: the physical case's colours (spec §3.3, the `bezel` rule), so magic numbers are allowed.
// swiftlint:disable no_magic_numbers

/// The colours of a physical game case (spec §3.3). Physical objects keep their real colours in both appearances.
///
/// Switch ports get the red case of the approved design; emulated and other games get a charcoal case of the same
/// shape (the `bezel` tone), so the red stays a Switch thing.
struct CaseColors: Equatable, Sendable {
    /// Front frame and spine.
    let front: RGBA
    /// The left side.
    let side: RGBA
    /// The top edge.
    let top: RGBA
    /// The bottom edge.
    let bottom: RGBA
    /// Text and the mark on the frame.
    let label: RGBA

    /// The red case (`#E60012`, `#C4000F`, `#D10011`, `#A3000C`).
    static let red = CaseColors(
        front: RGBA(hex: 0xE60012),
        side: RGBA(hex: 0xC4000F),
        top: RGBA(hex: 0xD10011),
        bottom: RGBA(hex: 0xA3000C),
        label: Palette.white
    )

    /// The charcoal case for emulated and other games (the `bezel` family).
    static let charcoal = CaseColors(
        front: Palette.charcoal,
        side: RGBA(hex: 0x1C1B1F),
        top: RGBA(hex: 0x2B2A30),
        bottom: RGBA(hex: 0x16120F),
        label: Palette.lamp
    )

    /// Print on the case's back panel: the light theme's inks, constant in both appearances.
    enum Print {
        /// Headings (`#242328`).
        static let ink = Palette.charcoal
        /// Body copy (`#5C5850`).
        static let soft = RGBA(hex: 0x5C5850)
        /// Footer (`#8F897D`).
        static let mute = RGBA(hex: 0x8F897D)
        /// The back panel is the palette's light tone mixed this far toward white.
        static let panelWhiteMix = 0.4
    }
}

// swiftlint:enable no_magic_numbers
