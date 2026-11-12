import SwiftUI

extension DesignTokens {
    /// TV (couch) mode, ADR 0052. Every size is a share of the screen height (a 10-foot UI), so 1080p and 4K look
    /// the same from the couch.
    enum TVMode {
        /// Titles: ~4–5% of the screen height.
        static let titleShare: CGFloat = 0.045
        /// Body text: never below ~2.5% of the screen height.
        static let bodyShare: CGFloat = 0.026
        /// Overscan safe area on every edge: ~5%.
        static let safeAreaShare: CGFloat = 0.05
        /// A shelf tile's height.
        static let shelfTileShare: CGFloat = 0.34
        /// A grid tile's height.
        static let gridTileShare: CGFloat = 0.27
        /// Space between tiles and between sections.
        static let gapShare: CGFloat = 0.025
        /// The focused tile grows by 9% (the plan's 8–10%), with no border on the art.
        static let focusScale: CGFloat = 1.09
        /// Unfocused tiles dim to this opacity.
        static let unfocusedOpacity: Double = 0.55
        /// The focused tile's soft shadow: radius and lift, as shares of the screen height.
        static let focusShadowShare: CGFloat = 0.03
        /// How far the focused tile lifts.
        static let focusLiftShare: CGFloat = 0.012
        /// Strength of the focus shadow.
        static let focusShadowOpacity: Double = 0.55
        /// Tile corner radius, as a share of the screen height.
        static let tileRadiusShare: CGFloat = 0.012
        /// Detail media height.
        static let detailMediaShare: CGFloat = 0.5
        /// The Start/Options menu panel's width, as a share of the screen width.
        static let menuWidthShare: CGFloat = 0.4
        /// How dark the backdrop scrim gets over the focused game's art.
        static let backdropScrimOpacity: Double = 0.78
        /// Focus motion (seconds); Reduce Motion turns it off.
        static let focusAnimation: Double = 0.18
        /// Games in the "Recently Played" shelf.
        static let recentLimit = 12
        /// Stick deflection that counts as a direction.
        static let stickThreshold: Float = 0.5
        /// A held direction repeats after this delay (seconds)…
        static let repeatDelay: Double = 0.4
        /// …every this many seconds.
        static let repeatInterval: Double = 0.12
        /// Half and double gaps are a gap divided or multiplied by this.
        static let gapDivisor: CGFloat = 2
        /// The simplest grid still has one column.
        static let minimumColumns = 1
        /// A 1080p screen's width and height, for previews and tests.
        static let previewWidth: CGFloat = 1920
        /// See ``previewWidth``.
        static let previewHeight: CGFloat = 1080
        /// A 1080p screen, for previews.
        static let previewScreen = CGSize(width: previewWidth, height: previewHeight)
        /// Half of it, for compact previews.
        static let previewThumbnail = CGSize(width: previewWidth / gapDivisor, height: previewHeight / gapDivisor)
    }
}
