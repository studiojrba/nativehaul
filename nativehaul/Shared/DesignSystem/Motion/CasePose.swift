import CoreGraphics

/// Where a hero case is during a switch (spec §4.1): horizontal offset, in-plane rotation and opacity.
struct CasePose: Equatable, Sendable {
    /// Horizontal offset (points; positive is to the right).
    let x: CGFloat
    /// In-plane rotation (degrees).
    let rotation: Double
    /// Opacity, 0…1.
    let opacity: Double

    /// At rest.
    static let rest = CasePose(x: 0, rotation: 0, opacity: 1)
}
