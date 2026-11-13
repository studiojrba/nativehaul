import Foundation

/// The pose maths of the case on Detail (spec §3.3 `BoxCase`): drag to spin, hover parallax, settle to the nearest
/// half turn, turn over. Pure functions of angles, so they are tested without a view.
enum CaseSpin {
    /// Resting yaw (degrees).
    static let restYaw: Double = -22
    /// Resting pitch (degrees).
    static let restPitch: Double = 6
    /// Yaw per point of horizontal drag.
    static let yawPerPoint = 0.45
    /// Pitch per point of vertical drag (dragging down tips the top back).
    static let pitchPerPoint = -0.2
    /// Pitch never goes beyond ±25° while dragging.
    static let pitchLimit: Double = 25
    /// Hover parallax: yaw at the area's edge (hover x runs −0.5…0.5).
    static let hoverYaw: Double = 10
    /// Hover parallax: pitch at the area's edge (hover y runs −0.5…0.5).
    static let hoverPitch: Double = 6
    /// A half turn: front to back.
    static let halfTurn: Double = 180
    private static let fullTurn: Double = 360
    /// A case has two covers: an odd number of half turns shows the back.
    private static let sides = 2

    /// The pose while dragging: the pose at the start of the drag plus the drag's translation (points).
    static func dragged(from start: CaseAngles, translation: CGSize) -> CaseAngles {
        let pitch = start.pitch + Double(translation.height) * pitchPerPoint
        return CaseAngles(
            yaw: start.yaw + Double(translation.width) * yawPerPoint,
            pitch: min(max(pitch, -pitchLimit), pitchLimit)
        )
    }

    /// The pose after letting go: the nearest half turn from rest (front or back), pitch back at rest.
    static func settled(_ angles: CaseAngles) -> CaseAngles {
        CaseAngles(yaw: settledYaw(angles.yaw), pitch: restPitch)
    }

    /// The nearest yaw of the form `rest + 180k`.
    static func settledYaw(_ yaw: Double) -> Double {
        ((yaw - restYaw) / halfTurn).rounded() * halfTurn + restYaw
    }

    /// The pose one more half turn on from where the case would settle ("Turn it over" / "Flip to the front").
    static func turnedOver(_ angles: CaseAngles) -> CaseAngles {
        CaseAngles(yaw: settledYaw(angles.yaw) + halfTurn, pitch: restPitch)
    }

    /// Whether the case shows (or would settle to) its back.
    static func isShowingBack(yaw: Double) -> Bool {
        let steps = Int(((settledYaw(yaw) - restYaw) / halfTurn).rounded())
        return !steps.isMultiple(of: sides)
    }

    /// The pose drawn: the pose plus hover parallax (`hover` in −0.5…0.5 across the area; zero while dragging).
    static func displayed(_ angles: CaseAngles, hover: CGPoint) -> CaseAngles {
        CaseAngles(
            yaw: angles.yaw + Double(hover.x) * hoverYaw,
            pitch: angles.pitch - Double(hover.y) * hoverPitch
        )
    }

    /// `yaw` folded into 0..<360.
    static func normalized(_ yaw: Double) -> Double {
        let folded = yaw.truncatingRemainder(dividingBy: fullTurn)
        return folded < 0 ? folded + fullTurn : folded
    }

    /// The sheen's CSS gradient angle for a face turned to `facing` degrees: `105° + facing × 0.3`.
    static func sheenAngle(facing: Double) -> Double {
        ShellLayoutValues.sheenBase + normalized(facing) * ShellLayoutValues.sheenPerDegree
    }

    /// The floor shadow's width as a share of the face's: `0.75 + |cos(yaw)| × 0.2`.
    static func floorWidthShare(yaw: Double) -> Double {
        ShellLayoutValues.floorBase + abs(cos(yaw * .pi / halfTurn)) * ShellLayoutValues.floorFacing
    }

    /// The design-system values the maths reads.
    private enum ShellLayoutValues {
        static let sheenBase = ShellLayout.GameCase.sheenBaseAngle
        static let sheenPerDegree = ShellLayout.GameCase.sheenAnglePerDegree
        static let floorBase = Double(ShellLayout.GameCase.floorBase)
        static let floorFacing = Double(ShellLayout.GameCase.floorFacing)
    }
}
