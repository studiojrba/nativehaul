import SwiftUI

extension DesignTokens {
    /// The Home page (ADR 0035): a big art-carried hero whose colour washes into the page behind it. Hero size, title
    /// size and wash strength come from the energy dial (``EnergyLevel``, ADR 0037).
    enum Home {
        /// Tight tracking for the hero title.
        static let heroTitleTracking: CGFloat = -1.2
        /// The hero's Play button width.
        static let playWidth: CGFloat = 220
        /// Darkest point of the scrim under the hero's text (bottom of the banner).
        static let scrimOpacity: Double = 0.78
        /// Where the scrim starts fading in, as a fraction of the banner height from the top.
        static let scrimStart: Double = 0.35
        /// Crossfade between heroes (seconds); well under a second (ADR 0025 item 7).
        static let crossfadeSeconds: Double = 0.7
        /// Diameter of a navigation dot.
        static let dotSize: CGFloat = 8
        /// How far down the page the wash reaches.
        static let ambientHeight: CGFloat = 900
        /// Blur on the wash.
        static let ambientBlur: CGFloat = 90
        /// Space between Home's sections.
        static let sectionSpacing: CGFloat = 40
    }
}
