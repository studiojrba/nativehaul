import SwiftUI

extension DesignTokens {
    /// The Home page (ADR 0035): a big art-carried hero whose colour washes into the page behind it. Hero size, title
    /// size and wash strength come from the energy dial (``EnergyLevel``, ADR 0037).
    enum Home {
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
        /// Space between Home's sections.
        static let sectionSpacing: CGFloat = 40
    }
}
