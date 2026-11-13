import SwiftUI

/// Central source of every visual constant used by nativehaul views.
///
/// Views must never contain literal spacing, sizes, radii, fonts, or colours. When Figma designs
/// arrive, re-skinning happens here (and in ``Theme``) without touching view structure or logic.
enum DesignTokens {
    /// Spacing scale (points).
    enum Spacing {
        static let none: CGFloat = 0
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    /// Corner radii (points).
    enum Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        /// Cover tiles (Meebits' ~16 px cards, ADR 0037).
        static let tile: CGFloat = 16
    }

    /// Stroke widths (points).
    enum Stroke {
        static let hairline: CGFloat = 1
        static let emphasis: CGFloat = 2
    }

    /// Cover-art metrics for the library grid.
    enum Cover {
        static let minWidth: CGFloat = 140
        static let maxWidth: CGFloat = 200
        /// Height divided by width for box art (portrait).
        static let aspectRatio: CGFloat = 1.5
        /// Width divided by height (inverse of ``aspectRatio``), for `.aspectRatio(_:)`.
        static let widthToHeight: CGFloat = 1 / aspectRatio
        static let detailWidth: CGFloat = 220
        static let stripWidth: CGFloat = 110
        static let placeholderSymbolScale: CGFloat = 0.3
    }

    /// Fixed layout sizes.
    enum Layout {
        static let sidebarMinWidth: CGFloat = 200
        static let detailMinWidth: CGFloat = 420
        static let windowMinWidth: CGFloat = 800
        static let windowMinHeight: CGFloat = 600
        static let statTileMinWidth: CGFloat = 160
        static let badgeSize: CGFloat = 56
        static let logMinHeight: CGFloat = 200
        static let formLabelWidth: CGFloat = 140
        static let setupMaxWidth: CGFloat = 640
    }

    /// Three-column game details layout.
    enum Details {
        static let rightRailWidth: CGFloat = 280
        static let heroHeight: CGFloat = 280
        static let infoLabelWidth: CGFloat = 104
    }

    /// Opacity levels.
    enum Opacity {
        static let subtle: Double = 0.08
        /// Selected rows and the active rail item: a faint accent wash.
        static let selection: Double = 0.16
        static let muted: Double = 0.4
        static let disabled: Double = 0.35
        static let overlay: Double = 0.6
        static let full: Double = 1
    }

    /// Point sizes behind ``Typography`` (ADR 0025): 13 pt UI text, big confident display sizes (serif display type
    /// runs a little larger than the old heavy rounded type to carry the same presence, ADR 0054).
    enum TypeScale {
        static let caption: CGFloat = 11
        static let body: CGFloat = 13
        static let launch: CGFloat = 15
        static let title: CGFloat = 17
        static let stat: CGFloat = 22
        static let largeTitle: CGFloat = 30
        static let display: CGFloat = 34
        static let rank: CGFloat = 34
        static let hero: CGFloat = 56
    }

    /// Typography roles (ADR 0025, re-pointed at the 0.1.0 faces in ADR 0054): Geist for UI text, Instrument Serif for
    /// display type (page headers, empty states, onboarding). Never rounded, never black-weight.
    enum Typography {
        /// The onboarding welcome.
        static let hero: Font = Typeface.display(TypeScale.hero)
        /// Page and section headers, empty-state titles.
        static let display: Font = Typeface.display(TypeScale.display)
        /// Display tracking: the serif sets well at its natural spacing, with a hair of tightening.
        static let displayTracking: CGFloat = -0.2
        static let largeTitle: Font = Typeface.display(TypeScale.largeTitle)
        static let title: Font = Typeface.sans(TypeScale.title, weight: .semibold)
        static let headline: Font = Typeface.sans(TypeScale.body, weight: .medium)
        static let body: Font = Typeface.sans(TypeScale.body)
        static let caption: Font = Typeface.sans(TypeScale.caption)
        static let captionEmphasis: Font = Typeface.sans(TypeScale.caption, weight: .semibold)
        /// Quiet section label inside dense panels.
        static let sectionLabel: Font = Typeface.sans(TypeScale.caption, weight: .medium)
        static let monospaced: Font = .system(size: TypeScale.body, design: .monospaced)
        static let monospacedSmall: Font = .system(size: TypeScale.caption, design: .monospaced)
        static let statValue: Font = Typeface.sans(TypeScale.stat, weight: .semibold).monospacedDigit()
        /// Rank numbers on the Stats story row.
        static let rank: Font = Typeface.display(TypeScale.rank)
        static let launch: Font = Typeface.sans(TypeScale.launch, weight: .medium)
        /// Smallest scale a fixed-width label may shrink to before it would otherwise clip.
        static let minimumScale: CGFloat = 0.75
    }

    /// The Builds page (ADR 0028).
    enum Builds {
        /// Longest edge showcase images are decoded at.
        static let showcaseDecodePixels: CGFloat = 1600
    }

    /// Colour sampled from a game's own artwork (ADR 0025): weak enough that text contrast never suffers.
    enum ArtTint {
        /// The detail hero's ambient wash, at its strongest point.
        static let heroGlowOpacity: Double = 0.32
        /// How far the wash reaches beyond the hero, as a multiple of its height.
        static let heroGlowReach: CGFloat = 1.8
        /// Blur applied to the wash.
        static let heroGlowBlur: CGFloat = 40
        /// How far past the hero's sides the wash extends, in blur radii (the centre column clips it, so it reads
        /// as an edge-to-edge glow rather than a box).
        static let heroGlowSpread: CGFloat = 3
        /// A tile field's bottom strength, as a share of its top (the field deepens downward).
        static let fieldFalloff: Double = 0.7
        /// Sampled colours are lifted to at least this saturation, so a muddy average still reads as colour.
        static let minimumSaturation: CGFloat = 0.45
        /// …and set to this brightness.
        static let brightness: CGFloat = 0.62
        /// Edge length the artwork is reduced to before sampling.
        static let sampleSize: CGFloat = 32
    }

    /// Animation durations (seconds).
    enum Motion {
        static let quick: Double = 0.15
        static let standard: Double = 0.25
    }

    /// Line limits for truncated text.
    enum Lines {
        static let single = 1
        static let title = 2
        /// Titles in narrow fixed columns (the details quick list): wrap rather than clip.
        static let wrappedTitle = 4
        static let summary = 6
    }
}
