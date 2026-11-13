import SwiftUI

// Layout constants are token source (spec §3, §3.0), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// The 0.1.0 app shell's geometry (spec §3 intro, §3.0): the content column, the floating nav island, the top bar,
/// the background wash and the launch overlay.
enum ShellLayout {
    /// The shared content column.
    enum Content {
        /// Maximum column width.
        static let maxWidth: CGFloat = 1280
        /// Left inset (clears the nav island).
        static let leadingInset: CGFloat = 128
        /// Right inset.
        static let trailingInset: CGFloat = 56
        /// Bottom padding of a page.
        static let bottomPadding: CGFloat = 128
    }

    /// The floating nav island (left, vertically centred).
    enum NavIsland {
        /// Distance from the window's left edge.
        static let leading: CGFloat = 20
        /// Padding inside the pill.
        static let padding: CGFloat = 6
        /// The pill's `cream` opacity.
        static let fillOpacity: Double = 0.75
        /// Nav button size.
        static let buttonSize: CGFloat = 48
        /// Nav icon size.
        static let iconSize: CGFloat = 19
        /// Icon stroke when active.
        static let activeStroke: CGFloat = 2.1
        /// Icon stroke when inactive.
        static let inactiveStroke: CGFloat = 1.7
        /// Inactive hover fill: `surface` at this opacity.
        static let hoverFillOpacity: Double = 0.5
        /// Builds badge dot.
        static let badgeSize: CGFloat = 8
        /// Builds badge offset from the button's top-right.
        static let badgeOffset: CGFloat = 10
        /// Builds badge `cream` ring.
        static let badgeRing: CGFloat = 2
        /// Divider width under the four buttons.
        static let dividerWidth: CGFloat = 24
        /// Appearance toggle size.
        static let toggleSize: CGFloat = 40
        /// Sun icon size.
        static let sunSize: CGFloat = 17
        /// Moon icon size.
        static let moonSize: CGFloat = 16
        /// Sun/moon cross-fade rotation (degrees).
        static let toggleRotation: Double = 90
        /// Sun/moon cross-fade scale.
        static let toggleScale: CGFloat = 0.5
        /// Tooltip horizontal padding.
        static let tooltipHorizontalPadding: CGFloat = 12
        /// Tooltip vertical padding.
        static let tooltipVerticalPadding: CGFloat = 6
        /// Tooltip slide-in distance.
        static let tooltipSlide: CGFloat = 4
    }

    /// The top bar: three frosted pills.
    enum TopBar {
        /// Top padding.
        static let top: CGFloat = 16
        /// Side padding.
        static let side: CGFloat = 20
        /// Pill height.
        static let pillHeight: CGFloat = 44
        /// Traffic-light dot size.
        static let trafficDot: CGFloat = 12
        /// Gap between the dots and the wordmark.
        static let wordmarkGap: CGFloat = 12
        /// Search field maximum width.
        static let searchMaxWidth: CGFloat = 448
        /// Search icon size.
        static let searchIcon: CGFloat = 16
        /// `⌘K` chip radius.
        static let kbdRadius: CGFloat = 6
        /// `⌘K` chip `ink` fill opacity.
        static let kbdFillOpacity: Double = 0.05
        /// Results dropdown radius.
        static let resultsRadius: CGFloat = 24
        /// Results dropdown padding.
        static let resultsPadding: CGFloat = 8
        /// Results dropdown distance below the field's top.
        static let resultsOffset: CGFloat = 56
        /// Maximum results shown.
        static let maxResults = 5
        /// Result cover thumbnail.
        static let resultThumb = CGSize(width: 36, height: 48)
        /// Result cover radius.
        static let resultThumbRadius: CGFloat = 8
    }

    /// The screen background wash: three radial gradients (spec §3.0 `Wash`).
    enum Wash {
        /// Gradient centres.
        static let centers = [UnitPoint(x: 0.15, y: 0.10), UnitPoint(x: 0.90, y: 0.20), UnitPoint(x: 0.60, y: 1.0)]
        /// Gradient ellipse sizes, as shares of the area (width, height).
        static let extents = [
            CGSize(width: 0.60, height: 0.50),
            CGSize(width: 0.50, height: 0.50),
            CGSize(width: 0.60, height: 0.60),
        ]
        /// Each colour fades to clear at this share of its radius.
        static let fadeStop: CGFloat = 0.70
        /// Background changes crossfade over this long.
        static let crossfade: Double = Motion.Duration.slow
        /// Home hero wash crossfade.
        static let heroCrossfade: Double = HeroTiming.wash
    }

    /// The desktop launch overlay.
    enum LaunchOverlay {
        /// `paper` opacity of the full-window layer.
        static let scrimOpacity: Double = 0.40
        /// Card radius.
        static let cardRadius: CGFloat = 40
        /// Card padding: top/bottom and leading.
        static let cardPadding: CGFloat = 28
        /// Card trailing padding.
        static let cardTrailingPadding: CGFloat = 48
        /// Gap between the cover and the text.
        static let gap: CGFloat = 28
        /// Cover width.
        static let coverWidth: CGFloat = 112
        /// Cover radius.
        static let coverRadius: CGFloat = 22
        /// Progress bar size.
        static let progressSize = CGSize(width: 288, height: 6)
        /// Progress fill duration (ease-in-out).
        static let progressDuration: Double = 2.4
    }
}

// swiftlint:enable no_magic_numbers
