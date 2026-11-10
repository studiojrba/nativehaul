import CoreGraphics

extension DesignTokens {
    /// The guided tour's bubble and hotspots (ADR 0040).
    enum Guide {
        /// Widest the bubble grows.
        static let bubbleMaxWidth: CGFloat = 520
        /// Size of Retriever's avatar.
        static let avatarSize: CGFloat = 40
        /// Width of a hotspot's glow ring.
        static let ringWidth: CGFloat = 3
        /// How far the ring sits outside its control.
        static let ringInset: CGFloat = -4
        /// Glow around the ring.
        static let glowRadius: CGFloat = 10
        /// Half a pulse, bright to faint (seconds).
        static let pulseHalfSeconds: Double = 0.7
        /// Faintest point of the pulse.
        static let pulseLow: Double = 0.35
        /// Caret blink period (seconds).
        static let caretSeconds: Double = 0.5
    }
}
