import CoreGraphics

/// One frame of a shelf's momentum glide (``ShelfPhysics/glideStep(offset:velocity:frame:maxOffset:)``).
struct GlideStep: Equatable, Sendable {
    /// The new offset, clamped to the scroll range.
    let offset: CGFloat
    /// The slowed velocity (points per millisecond).
    let velocity: Double
    /// `true` when the glide should stop (too slow, or at an end).
    let isFinished: Bool
}
