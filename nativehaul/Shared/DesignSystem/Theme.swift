import AppKit
import SwiftUI

/// Semantic colours (ADR 0025, re-pointed at the 0.1.0 token set in ADR 0054). Views reference roles
/// (`Theme.paper`, `Theme.ink`), never concrete colours.
///
/// Every colour here follows the view's appearance: it is an `NSColor` with a dynamic provider that picks
/// ``ThemeTokens/light`` or ``ThemeTokens/dark``, so SwiftUI resolves it through the environment's `colorScheme`
/// (and AppKit through the effective appearance). One token set, no per-mode component forks.
enum Theme {
    // MARK: Core tokens (spec §2.1)

    /// App background.
    static let paper = dynamic(\.paper)
    /// Sunken surface: inputs, chips, tracks.
    static let paper2 = dynamic(\.paper2)
    /// Raised surface: cards, active pills.
    static let surface = dynamic(\.surface)
    /// Switch thumb.
    static let knob = dynamic(\.knob)
    /// Primary text.
    static let ink = dynamic(\.ink)
    /// Secondary text.
    static let inkSoft = dynamic(\.inkSoft)
    /// Tertiary text, eyebrows.
    static let inkMute = dynamic(\.inkMute)
    /// Lit fill.
    static let cream = dynamic(\.cream)
    /// Second lit fill.
    static let cream2 = dynamic(\.cream2)
    /// The palette cream, constant in both modes.
    static let lamp = Palette.lamp.color
    /// The ember accent, spent sparingly: primary actions, active dots, switches, progress, focus.
    static let accent = Palette.ember.color
    /// Text and icons on ``accent``.
    static let onAccent = dynamic(\.onAccent)
    /// Hairline divider.
    static let hairline = dynamic(\.hair)
    /// A brighter hairline for hover rings and dashed placeholders.
    static let hairlineStrong = dynamic(\.hairStrong)
    /// Physical hardware (TV frame).
    static let bezel = dynamic(\.bezel)
    /// Cast shadow under physical objects.
    static let floor = dynamic(\.floor)
    /// Success, valid, ready.
    static let success = dynamic(\.ok)
    /// Caution (functional status only).
    static let warning = dynamic(\.warning)
    /// Failure (functional status only).
    static let danger = dynamic(\.danger)
    /// Text selection background.
    static let selection = dynamic(\.selection)
    /// Frosted-glass fill.
    static let frostFill = dynamic(\.frostFill)
    /// Frosted-glass inner edge (clear by day).
    static let frostEdge = dynamic(\.frostEdge)
    /// The build-status "ready" dot.
    static let readyDot = Palette.readyDot.color

    /// The wash for `slot`, following the appearance.
    static func wash(_ slot: WashSlot) -> Color {
        dynamic(light: ThemeTokens.light.wash(slot), dark: ThemeTokens.dark.wash(slot))
    }

    // MARK: Roles kept for existing call sites (mapped onto the tokens above)

    /// The window canvas: ``paper``.
    static let canvas = paper
    /// Same as ``canvas``.
    static let background = paper
    /// The icon rail: the sunken paper, a step below the canvas.
    static let sidebar = paper2
    /// Two steps up: hovered and raised surfaces (the second lit fill).
    static let surfaceRaised = cream2
    /// Artwork placeholders.
    static let placeholder = paper2
    /// Primary text: ``ink``.
    static let primaryText = ink
    /// Secondary text: ``inkSoft``.
    static let secondaryText = inkSoft
    /// Tertiary text: ``inkMute``.
    static let tertiaryText = inkMute
    /// Same as ``hairline``.
    static let separator = hairline
    /// Muted neutral for informational tags.
    static let info = inkMute
    /// HLTB estimates are labelled, not coloured: quiet and monochrome.
    static let estimate = inkSoft
    /// A faint accent wash for selected rows.
    static let accentSoft = accent.opacity(DesignTokens.Opacity.selection)
    /// Play's daylight gradient: ember into a deeper ember (the dark treatment is ``EmberFill``).
    static let playGradient = LinearGradient(
        colors: [accent, AccentTokens.emberDeep.color],
        startPoint: .leading,
        endPoint: .trailing
    )
    /// Behind a trailer: the evening bezel, never pure black.
    static let mediaBackdrop = Palette.mediaBackdrop.color
    /// Text drawn over artwork behind a dark scrim: warm near-white in both appearances.
    static let onArtwork = Palette.onArtwork.color
    /// The scrim laid under text on artwork: the evening tone, never pure black.
    static let artworkScrim = Palette.evening.color

    // MARK: Resolution

    /// A colour that follows the appearance, from a token path.
    private static func dynamic(_ token: KeyPath<ThemeTokens, RGBA>) -> Color {
        dynamic(light: ThemeTokens.light[keyPath: token], dark: ThemeTokens.dark[keyPath: token])
    }

    /// A colour that follows the appearance.
    private static func dynamic(light: RGBA, dark: RGBA) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return (isDark ? dark : light).nsColor
        })
    }
}
