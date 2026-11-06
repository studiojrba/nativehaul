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
        static let windowMinWidth: CGFloat = 960
        static let windowMinHeight: CGFloat = 600
        static let statTileMinWidth: CGFloat = 160
        static let badgeSize: CGFloat = 56
        static let logMinHeight: CGFloat = 200
        static let formLabelWidth: CGFloat = 140
    }

    /// Icon rail (collapsed: icons only; expanded on hover: icons + labels).
    enum Rail {
        static let collapsedWidth: CGFloat = 56
        static let expandedWidth: CGFloat = 232
        static let itemHeight: CGFloat = 36
        static let iconWidth: CGFloat = 24
        static let shadowRadius: CGFloat = 12
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
        static let muted: Double = 0.4
        static let disabled: Double = 0.35
        static let overlay: Double = 0.6
        static let full: Double = 1
    }

    /// Typography roles.
    enum Typography {
        static let largeTitle: Font = .largeTitle.weight(.bold)
        static let title: Font = .title2.weight(.semibold)
        static let headline: Font = .headline
        static let body: Font = .body
        static let caption: Font = .caption
        static let captionEmphasis: Font = .caption.weight(.semibold)
        static let monospaced: Font = .system(.body, design: .monospaced)
        static let monospacedSmall: Font = .system(.caption, design: .monospaced)
        static let statValue: Font = .system(.title, design: .rounded).weight(.bold)
        static let launch: Font = .title3.weight(.bold)
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
        static let summary = 6
    }
}
