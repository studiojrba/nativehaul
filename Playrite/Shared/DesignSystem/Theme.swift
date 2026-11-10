import SwiftUI

/// Semantic colours (ADR 0025). Views reference roles (`Theme.accent`), never concrete colours; both appearances
/// come from ``Palette``.
enum Theme {
    /// The one electric accent, spent only on Play, the active nav item, links and the wordmark (ADR 0037).
    static let accent = Color(nsColor: Palette.color(Palette.accent))
    /// Play's gradient, the signature surface: the accent running into a deeper, hotter red (ADR 0037).
    static let playGradient = LinearGradient(
        colors: [accent, Color(nsColor: Palette.color(Palette.accentDeep))],
        startPoint: .leading,
        endPoint: .trailing
    )
    /// Text and icons on ``accent``.
    static let onAccent = Color(nsColor: Palette.color(Palette.onAccent))
    /// A faint accent wash for selected rows.
    static let accentSoft = accent.opacity(DesignTokens.Opacity.selection)
    /// The window canvas (near-black in dark mode).
    static let canvas = Color(nsColor: Palette.color(Palette.canvas))
    /// Same as ``canvas``; kept for existing call sites.
    static let background = canvas
    /// The icon rail: deliberately dimmer than the canvas.
    static let sidebar = Color(nsColor: Palette.color(Palette.sidebar))
    /// One step up from the canvas: cards, chips, tiles.
    static let surface = Color(nsColor: Palette.color(Palette.surface))
    /// Two steps up: hovered and raised surfaces.
    static let surfaceRaised = Color(nsColor: Palette.color(Palette.surfaceRaised))
    /// The floating sidebar's shadow, the one shadow in the app (ADR 0037, round 2).
    /// Behind a trailer (the video's own letterbox colour), ADR 0038.
    static let mediaBackdrop = Color.black
    static let panelShadow = Color.black.opacity(DesignTokens.FloatingRail.shadowOpacity)
    /// Hairline borders, used instead of shadows.
    static let hairline = Color(nsColor: Palette.color(Palette.hairline))
    /// A brighter hairline for hover rings.
    static let hairlineStrong = Color(nsColor: Palette.color(Palette.hairlineStrong))
    static let placeholder = Color(nsColor: Palette.color(Palette.surfaceRaised))
    static let primaryText = Color(nsColor: Palette.color(Palette.textPrimary))
    static let secondaryText = Color(nsColor: Palette.color(Palette.textSecondary))
    static let tertiaryText = Color(nsColor: Palette.color(Palette.textTertiary))
    static let separator = hairline
    static let success = Color(nsColor: Palette.color(Palette.success))
    static let warning = Color(nsColor: Palette.color(Palette.warning))
    static let danger = Color(nsColor: Palette.color(Palette.danger))
    /// Muted neutral for informational tags (formerly blue).
    static let info = Color(nsColor: Palette.color(Palette.muted))
    /// HLTB estimates are labelled, not coloured: quiet and monochrome.
    static let estimate = secondaryText
    /// Text drawn over artwork behind a dark scrim: light in both appearances, because the scrim is always dark.
    static let onArtwork = Color(nsColor: .white)
    /// The scrim colour laid under text on artwork.
    static let artworkScrim = Color(nsColor: .black)
}
