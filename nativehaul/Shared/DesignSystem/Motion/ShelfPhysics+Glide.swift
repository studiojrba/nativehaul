import CoreGraphics
import Foundation

extension ShelfPhysics {
    /// Below this release speed (points per millisecond) no glide starts at all.
    static let startVelocity: Double = 0.05
    /// Frames longer than this (seconds) are treated as this long, so a hitch never throws the shelf.
    static let maximumFrame: Double = 0.048
    /// Milliseconds per second (velocities are in points per millisecond, as in the reference).
    static let millisecondsPerSecond: Double = 1000

    /// One momentum frame: the new offset and velocity, and whether the glide is over (too slow, or at an end).
    /// `velocity` is in points per millisecond; positive scrolls toward the end.
    static func glideStep(
        offset: CGFloat,
        velocity: Double,
        frame seconds: Double,
        maxOffset: CGFloat
    ) -> GlideStep {
        let frame = min(max(seconds, 0), maximumFrame)
        let moved = offset + CGFloat(velocity * frame * millisecondsPerSecond)
        let clamped = min(max(moved, 0), max(maxOffset, 0))
        let slowed = velocity * friction(over: frame)
        let isFinished = abs(slowed) <= stopVelocity || clamped <= 0 || clamped >= maxOffset
        return GlideStep(offset: clamped, velocity: slowed, isFinished: isFinished)
    }

    /// The velocity a glide starts with on release: none if the pointer was held still for over ``holdStill`` seconds,
    /// or if it is too slow to bother.
    static func releaseVelocity(_ velocity: Double, heldStillFor seconds: Double) -> Double {
        seconds > holdStill || abs(velocity) <= startVelocity ? 0 : velocity
    }

    /// Where one chevron click pages to: 90% of the visible width (at least ``minimumPage``) in `direction` (−1 or 1),
    /// clamped to the scroll range.
    static func pageTarget(from offset: CGFloat, direction: Int, visibleWidth: CGFloat, maxOffset: CGFloat) -> CGFloat {
        let step = max(minimumPage, visibleWidth * pageShare)
        return min(max(offset + CGFloat(direction) * step, 0), max(maxOffset, 0))
    }

    /// The paging glide's offset `elapsed` seconds in.
    static func pageOffset(from start: CGFloat, to target: CGFloat, elapsed: Double) -> CGFloat {
        start + (target - start) * CGFloat(pageEasing(elapsed / pageDuration))
    }

    /// Whether each paging chevron should show at `offset` within 0…`maxOffset`.
    static func showsArrows(offset: CGFloat, maxOffset: CGFloat) -> (leading: Bool, trailing: Bool) {
        (offset > edgeTolerance, offset < maxOffset - edgeTolerance)
    }

    /// A velocity sample in points per millisecond from a pointer move (`delta` points over `seconds`), smoothed
    /// against the previous estimate. Positive when the content should scroll toward the end (pointer moving left).
    static func dragVelocity(previous: Double, pointerDelta delta: CGFloat, seconds: Double) -> Double {
        let milliseconds = max(1, seconds * millisecondsPerSecond)
        return smoothedVelocity(previous: previous, sample: Double(-delta) / milliseconds)
    }
}
