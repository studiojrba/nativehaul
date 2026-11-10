import CoreGraphics

extension DesignTokens {
    /// The light theme's feel (ADR 0040, after Kriss): soft shadows instead of borders, frosted floating panels,
    /// pastel scene tints and gentle fade-and-rise entrances.
    enum Light {
        /// Card shadow strength.
        static let cardShadowOpacity: Double = 0.09
        /// Card shadow blur.
        static let cardShadowRadius: CGFloat = 18
        /// Card shadow drop.
        static let cardShadowY: CGFloat = 6
        /// How much warm cream sits over a frosted panel's blur, so it never reads as cold glass.
        static let frostTintOpacity: Double = 0.45
        /// Brightness of a pastel scene tint.
        static let pastelBrightness: CGFloat = 0.97
        /// How far down the window a scene tint reaches before fading into the canvas (share of height).
        static let tintReach: CGFloat = 0.75
        /// Distance an entrance rises from (points).
        static let riseDistance: CGFloat = 14
        /// Length of an entrance (seconds; sub-second, ADR 0037).
        static let riseSeconds: Double = 0.45
        /// Delay between staggered entrances (seconds).
        static let riseStagger: Double = 0.05
        /// Most stagger steps, so a long page never waits.
        static let riseMaxSteps = 6
        /// How long a scene tint takes to change colour (seconds).
        static let tintChangeSeconds: Double = 0.6
    }
}
