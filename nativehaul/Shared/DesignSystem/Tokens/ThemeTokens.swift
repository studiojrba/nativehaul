import SwiftUI

/// The one token set (spec §2, ADR 0054): every colour role the UI uses, with a ``light`` and a ``dark`` instance.
///
/// Views do not read this directly; they use the appearance-following colours on ``Theme`` (`Theme.paper`), which
/// resolve through the view's `colorScheme`. Code that needs the raw value for maths (washes, tones, tests) reads
/// ``resolved(for:)`` or `@Environment(\.themeTokens)`.
struct ThemeTokens: Sendable, Hashable {
    /// App background.
    let paper: RGBA
    /// Sunken surface: inputs, chips, tracks.
    let paper2: RGBA
    /// Raised surface: cards, active pills.
    let surface: RGBA
    /// Switch thumb.
    let knob: RGBA
    /// Primary text.
    let ink: RGBA
    /// Secondary text.
    let inkSoft: RGBA
    /// Tertiary text, eyebrows.
    let inkMute: RGBA
    /// Lit fill: user chat bubbles, tinted panels.
    let cream: RGBA
    /// Second lit fill.
    let cream2: RGBA
    /// The palette cream, constant in both modes (text on ink, glyphs).
    let lamp: RGBA
    /// The ember accent (constant). One accent, spent sparingly.
    let accent: RGBA
    /// Text and glyphs on the accent.
    let onAccent: RGBA
    /// Hairline divider.
    let hair: RGBA
    /// A stronger hairline for hover rings and dashed placeholders.
    let hairStrong: RGBA
    /// Physical hardware (the TV frame) keeps its real colour.
    let bezel: RGBA
    /// Cast-shadow colour under physical objects, and the base of warm elevation.
    let floor: RGBA
    /// Success, valid, ready.
    let ok: RGBA
    /// Caution (functional status only, never decoration).
    let warning: RGBA
    /// Failure (functional status only; distinct from the accent).
    let danger: RGBA
    /// Text selection background.
    let selection: RGBA
    /// Frosted-glass fill (spec §2.3).
    let frostFill: RGBA
    /// Frosted-glass 1px inner edge (clear by day).
    let frostEdge: RGBA
    /// Wash slots, in ``WashSlot`` order.
    let washes: Washes

    /// The wash for `slot` in this appearance.
    func wash(_ slot: WashSlot) -> RGBA {
        switch slot {
        case .sky: washes.sky
        case .blush: washes.blush
        case .mint: washes.mint
        case .butter: washes.butter
        case .cream: washes.cream
        case .peach: washes.peach
        case .lilac: washes.lilac
        }
    }

    /// The token set for `scheme`.
    static func resolved(for scheme: ColorScheme) -> ThemeTokens {
        scheme == .dark ? dark : light
    }

    /// The seven wash values of one appearance (spec §2.2).
    struct Washes: Sendable, Hashable {
        /// Sky.
        let sky: RGBA
        /// Blush.
        let blush: RGBA
        /// Mint.
        let mint: RGBA
        /// Butter.
        let butter: RGBA
        /// Cream.
        let cream: RGBA
        /// Peach.
        let peach: RGBA
        /// Lilac.
        let lilac: RGBA
    }
}
