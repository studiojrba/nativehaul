import CoreGraphics
@testable import nativehaul
import QuartzCore
import Testing

/// Spec §3.3: which faces of the case show, and where the projection puts them.
struct CaseProjectionTests {
    private let projection = CaseProjection(width: 300, height: 484, depth: 20, perspective: 1800)

    private func project(_ face: CaseFace, _ point: CGPoint, at angles: CaseAngles) -> CGPoint {
        let matrix = projection.transform(for: face, at: angles)
        let x = point.x * matrix.m11 + point.y * matrix.m21 + matrix.m41
        let y = point.x * matrix.m12 + point.y * matrix.m22 + matrix.m42
        let weight = point.x * matrix.m14 + point.y * matrix.m24 + matrix.m44
        return CGPoint(x: x / weight, y: y / weight)
    }

    @Test func atRestTheFrontSpineAndBottomShow() {
        let faces = Set(projection.visibleFaces(at: .rest))
        #expect(faces.contains(.front))
        #expect(faces.contains(.spine))
        #expect(!faces.contains(.back))
        #expect(!faces.contains(.side))
        #expect(!faces.contains(.top))
    }

    @Test func turnedOverTheBackAndTheOtherSideShow() {
        let faces = Set(projection.visibleFaces(at: CaseSpin.turnedOver(.rest)))
        #expect(faces.contains(.back))
        #expect(faces.contains(.side))
        #expect(!faces.contains(.front))
        #expect(!faces.contains(.spine))
    }

    @Test(arguments: Array(stride(from: -180.0, through: 540.0, by: 15.0)))
    func exactlyOneCoverShowsAtEveryTurn(yaw: Double) {
        let faces = projection.visibleFaces(at: CaseAngles(yaw: yaw + 1, pitch: CaseSpin.restPitch))
        #expect(faces.contains(.front) != faces.contains(.back))
    }

    @Test func facingStraightOnTheFrontFillsItsFrameScaledByDepth() {
        let straight = CaseAngles(yaw: 0, pitch: 0)
        let topLeft = project(.front, .zero, at: straight)
        let scale = 1800.0 / (1800.0 - 10.0)
        #expect(abs(topLeft.x - (150 - 150 * scale)) < 1e-6)
        #expect(abs(topLeft.y - (242 - 242 * scale)) < 1e-6)
    }

    @Test func atRestTheSpineSitsOnTheRight() {
        let centre = project(.spine, CGPoint(x: 10, y: 242), at: .rest)
        // The spine view is laid out centred on the case (its own centre at x = 10); it projects to the right.
        #expect(centre.x > 10 + 100)
    }
}
