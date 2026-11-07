import SwiftUI

/// Central source of every visual constant used by Playrite views.
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

    /// Icon rail (collapsed: icons only; expanded on hover: icons + labels).
    enum Rail {
        static let collapsedWidth: CGFloat = 56
        static let expandedWidth: CGFloat = 232
        static let itemHeight: CGFloat = 36
        static let iconWidth: CGFloat = 24
    }

    /// Three-column game details layout.
    enum Details {
        static let quickListWidth: CGFloat = 220
        static let rightRailWidth: CGFloat = 280
        static let heroHeight: CGFloat = 280
        static let launchButtonHeight: CGFloat = 48
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

    /// Point sizes behind ``Typography`` (ADR 0025): 13 pt UI text, big confident display sizes.
    enum TypeScale {
        static let caption: CGFloat = 11
        static let body: CGFloat = 13
        static let launch: CGFloat = 15
        static let title: CGFloat = 17
        static let stat: CGFloat = 22
        static let largeTitle: CGFloat = 26
        static let display: CGFloat = 28
        static let rank: CGFloat = 34
        static let hero: CGFloat = 44
    }

    /// Typography roles (ADR 0025): small, precise UI text (13 pt) for data, and big, tight, confident display type
    /// — (Not Boring) style — for page headers, empty states and onboarding.
    enum Typography {
        /// The onboarding welcome.
        static let hero: Font = .system(size: TypeScale.hero, weight: .black, design: .rounded)
        /// Page and section headers, empty-state titles.
        static let display: Font = .system(size: TypeScale.display, weight: .heavy, design: .rounded)
        /// Tight tracking for display type.
        static let displayTracking: CGFloat = -0.6
        static let largeTitle: Font = .system(size: TypeScale.largeTitle, weight: .bold)
        static let title: Font = .system(size: TypeScale.title, weight: .semibold)
        static let headline: Font = .system(size: TypeScale.body, weight: .semibold)
        static let body: Font = .system(size: TypeScale.body)
        static let caption: Font = .system(size: TypeScale.caption)
        static let captionEmphasis: Font = .system(size: TypeScale.caption, weight: .semibold)
        /// Quiet section label inside dense panels (Linear-style small header).
        static let sectionLabel: Font = .system(size: TypeScale.caption, weight: .semibold)
        static let monospaced: Font = .system(size: TypeScale.body, design: .monospaced)
        static let monospacedSmall: Font = .system(size: TypeScale.caption, design: .monospaced)
        static let statValue: Font = .system(size: TypeScale.stat, weight: .bold, design: .rounded)
        /// Rank numbers on the Stats story row.
        static let rank: Font = .system(size: TypeScale.rank, weight: .black, design: .rounded)
        static let launch: Font = .system(size: TypeScale.launch, weight: .bold)
        /// Smallest scale a fixed-width label may shrink to before it would otherwise clip.
        static let minimumScale: CGFloat = 0.75
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
        /// A card's hover wash.
        static let hoverOpacity: Double = 0.14
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
