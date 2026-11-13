import CoreGraphics

/// One keyframe of the hero case's incoming overshoot (spec §4.1).
struct CaseKeyframe: Sendable, Hashable {
    /// Progress through the animation, 0…1.
    let progress: Double
    /// Horizontal offset at this point (points).
    let x: CGFloat
    /// Rotation at this point (degrees).
    let rotation: Double
}
