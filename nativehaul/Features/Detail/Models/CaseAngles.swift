import Foundation

/// The case's turn on Detail (spec §3.3), in degrees: `yaw` about the vertical axis (CSS `rotateY`), `pitch` about
/// the horizontal axis (CSS `rotateX`).
struct CaseAngles: Equatable, Sendable {
    /// Rotation about the vertical axis, degrees. Unbounded: each turn over adds 180.
    var yaw: Double
    /// Rotation about the horizontal axis, degrees.
    var pitch: Double

    /// The resting pose: rotateY −22°, rotateX 6°.
    static let rest = CaseAngles(yaw: CaseSpin.restYaw, pitch: CaseSpin.restPitch)
}
