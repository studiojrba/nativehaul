import Foundation

/// Shelf drag, momentum and paging (spec §4.2).
enum ShelfPhysics {
    /// Below this pointer travel (points) a gesture is still a click.
    static let dragThreshold: CGFloat = 5
    /// Velocity smoothing: share of the newest sample.
    static let velocityNewShare: Double = 0.8
    /// Velocity smoothing: share of the previous estimate.
    static let velocityOldShare: Double = 0.2
    /// Momentum friction applied per frame.
    static let friction: Double = 0.95
    /// The frame the friction is defined for (seconds; 16ms).
    static let frameInterval: Double = 0.016
    /// The glide stops below this speed (points per millisecond).
    static let stopVelocity: Double = 0.02
    /// Held still this long (seconds) before release means no glide.
    static let holdStill: Double = 0.08
    /// One chevron click pages by this share of the visible width…
    static let pageShare: CGFloat = 0.9
    /// …but at least this far.
    static let minimumPage: CGFloat = 200
    /// Paging glide duration (easing `1 − (1−t)³`).
    static let pageDuration: Double = 0.52
    /// Arrows hide within this distance of either end.
    static let edgeTolerance: CGFloat = 2
    /// Padding inside the scrollport above cards, so shadows never clip.
    static let shadowPaddingTop: CGFloat = 32
    /// Padding inside the scrollport below cards.
    static let shadowPaddingBottom: CGFloat = 56

    /// The paging glide's easing, `1 − (1−t)³`, for `t` in 0…1.
    static func pageEasing(_ progress: Double) -> Double {
        let remaining = 1 - min(max(progress, 0), 1)
        return 1 - remaining * remaining * remaining
    }

    /// Friction for an arbitrary frame length (keeps the glide the same at any refresh rate).
    static func friction(over seconds: Double) -> Double {
        pow(friction, seconds / frameInterval)
    }

    /// The smoothed velocity after a new sample.
    static func smoothedVelocity(previous: Double, sample: Double) -> Double {
        sample * velocityNewShare + previous * velocityOldShare
    }
}
