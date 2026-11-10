import SwiftUI

/// Central source of every visual constant used by Retriever views.
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
    /// Corner radii: generously rounded in the light theme (ADR 0040).
    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let lg: CGFloat = 18
        /// Cover tiles (Meebits' ~16 px cards, ADR 0037).
        static let tile: CGFloat = 20
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
        /// The largest headline.
        static var hero: Font {
            TypeFace.font(size: TypeScale.hero, weight: .semibold)
        }

        /// Page and section headers, empty-state titles.
        static var display: Font {
            TypeFace.font(size: TypeScale.display, weight: .semibold)
        }

        /// Tracking for ``display``.
        static var displayTracking: CGFloat {
            TypeFace.headlineTracking(for: TypeScale.display)
        }

        static var largeTitle: Font {
            TypeFace.font(size: TypeScale.largeTitle, weight: .semibold)
        }

        static var title: Font {
            TypeFace.font(size: TypeScale.title, weight: .semibold)
        }

        static var headline: Font {
            TypeFace.font(size: TypeScale.body, weight: .semibold)
        }

        static var body: Font {
            TypeFace.font(size: TypeScale.body)
        }

        static var caption: Font {
            TypeFace.font(size: TypeScale.caption)
        }

        static var captionEmphasis: Font {
            TypeFace.font(size: TypeScale.caption, weight: .semibold)
        }

        /// Quiet section label inside dense panels (Linear-style small header).
        static var sectionLabel: Font {
            TypeFace.font(size: TypeScale.caption, weight: .semibold)
        }

        /// Figures (times, sizes, counts) in the same sans, with tabular numbers (ADR 0041).
        static var figures: Font {
            TypeFace.figures(size: TypeScale.body)
        }

        /// Small figures.
        static var figuresSmall: Font {
            TypeFace.figures(size: TypeScale.caption)
        }

        static var statValue: Font {
            TypeFace.figures(size: TypeScale.stat, weight: .semibold)
        }

        /// Rank numbers on the Stats story row.
        static var rank: Font {
            TypeFace.figures(size: TypeScale.rank, weight: .semibold)
        }

        static var launch: Font {
            TypeFace.font(size: TypeScale.launch, weight: .semibold)
        }

        /// Smallest scale a fixed-width label may shrink to before it would otherwise clip.
        static let minimumScale: CGFloat = 0.75
    }

    /// The Builds page (ADR 0028).
    enum Builds {
        /// The job detail's share of the page width; the queue keeps the rest.
        static let detailShare: CGFloat = 0.666_666_7
        /// Height of the segmented progress bar.
        static let progressHeight: CGFloat = 10
        /// Gap between progress segments.
        static let segmentGap: CGFloat = 3
        /// Seconds each showcase screenshot stays up.
        static let slideSeconds: Double = 3
        /// Crossfade between screenshots (seconds).
        static let crossfadeSeconds: Double = 0.8
        /// Longest edge showcase images are decoded at.
        static let showcaseDecodePixels: CGFloat = 1600
    }

    /// Colour sampled from a game's own artwork (ADR 0025): weak enough that text contrast never suffers.
    enum ArtTint {
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
