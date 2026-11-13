import CoreGraphics
@testable import nativehaul
import Testing

/// Spec §3.3 `BoxCase`: drag maths, the pitch clamp, settling to the nearest half turn, turning over, hover parallax,
/// the sheen angle and the floor shadow.
struct CaseSpinTests {
    private let tolerance = 1e-9

    @Test func restIsTheDesignedPose() {
        #expect(CaseAngles.rest == CaseAngles(yaw: -22, pitch: 6))
    }

    @Test func dragTurnsYawAt0point45AndPitchAtMinus0point2PerPoint() {
        let pose = CaseSpin.dragged(from: .rest, translation: CGSize(width: 100, height: 10))
        #expect(abs(pose.yaw - 23) < tolerance)
        #expect(abs(pose.pitch - 4) < tolerance)
    }

    @Test func pitchIsClampedToTwentyFiveDegreesEitherWay() {
        #expect(CaseSpin.dragged(from: .rest, translation: CGSize(width: 0, height: -1000)).pitch == 25)
        #expect(CaseSpin.dragged(from: .rest, translation: CGSize(width: 0, height: 1000)).pitch == -25)
    }

    @Test(arguments: [
        (-22.0, -22.0), (60.0, -22.0), (70.0, 158.0), (158.0, 158.0), (-100.0, -22.0), (-120.0, -202.0), (
            -150.0,
            -202.0
        ),
        (400.0, 338.0),
    ])
    func settlingGoesToTheNearestHalfTurnFromRest(yaw: Double, expected: Double) {
        #expect(CaseSpin.settledYaw(yaw) == expected)
        #expect(CaseSpin.settled(CaseAngles(yaw: yaw, pitch: 20)).pitch == CaseSpin.restPitch)
    }

    @Test func turningOverAddsHalfATurnToWhereItWouldSettle() {
        let back = CaseSpin.turnedOver(.rest)
        #expect(back.yaw == 158)
        #expect(CaseSpin.isShowingBack(yaw: back.yaw))
        let front = CaseSpin.turnedOver(back)
        #expect(front.yaw == 338)
        #expect(!CaseSpin.isShowingBack(yaw: front.yaw))
        #expect(CaseSpin.isShowingBack(yaw: -202))
    }

    @Test func hoverAddsParallax() {
        let pose = CaseSpin.displayed(.rest, hover: CGPoint(x: 0.5, y: -0.5))
        #expect(pose.yaw == -17)
        #expect(pose.pitch == 9)
        #expect(CaseSpin.displayed(.rest, hover: .zero) == .rest)
    }

    @Test func sheenAngleFollowsTheFacing() {
        #expect(abs(CaseSpin.sheenAngle(facing: 0) - 105) < tolerance)
        #expect(abs(CaseSpin.sheenAngle(facing: -22) - (105 + 338 * 0.3)) < tolerance)
    }

    @Test func floorShadowIsWidestFacingTheViewer() {
        #expect(abs(CaseSpin.floorWidthShare(yaw: 0) - 0.95) < tolerance)
        #expect(abs(CaseSpin.floorWidthShare(yaw: 90) - 0.75) < tolerance)
        #expect(abs(CaseSpin.floorWidthShare(yaw: 180) - 0.95) < tolerance)
    }
}
