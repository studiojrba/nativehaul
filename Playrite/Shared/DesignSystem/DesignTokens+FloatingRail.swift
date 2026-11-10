import SwiftUI

extension DesignTokens {
    /// The floating sidebar (J.R, design round 2, ADR 0037): a rounded panel inset from the window edges, vertically
    /// centred, floating over one continuous page background. Structural, so the same at every dial position.
    enum FloatingRail {
        /// Space between the panel and the window's leading edge, and its preferred space above and below.
        static let margin: CGFloat = Spacing.lg
        /// The panel's corner radius.
        static let cornerRadius: CGFloat = Radius.tile
        /// Width the page keeps clear for the collapsed panel and its margins. The expanded panel floats over the page.
        static let reservedWidth: CGFloat = margin + Rail.collapsedWidth + margin
        /// Strength of the panel's shadow.
        static let shadowOpacity: Double = 0.16
        /// Blur of the panel's shadow.
        static let shadowRadius: CGFloat = 26
        /// Downward offset of the panel's shadow.
        static let shadowOffset: CGFloat = 6
    }
}
