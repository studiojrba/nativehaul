import CoreGraphics
@testable import nativehaul
import Testing

/// Spec §4.1: the hero case's slide-out / slide-in, as CSS evaluates it.
struct CaseChoreographyTests {
    private let travel: CGFloat = 620

    @Test func cubicBezierMatchesCSS() {
        let linear = CubicBezier(x1: 0, y1: 0, x2: 1, y2: 1)
        #expect(abs(linear.value(at: 0.3) - 0.3) < 0.0001)
        let ease = Motion.cssEase
        #expect(abs(ease.value(at: 0.5) - 0.8024) < 0.001)
        #expect(Motion.settleCurve.value(at: 0) == 0)
        #expect(Motion.settleCurve.value(at: 1) == 1)
        #expect(Motion.settleCurve.value(at: 2) == 1)
    }

    @Test func theOutgoingCaseLeavesToTheRight() {
        #expect(CaseChoreography.outgoing(elapsed: 0, travel: travel) == .rest)
        let gone = CaseChoreography.outgoing(elapsed: HeroTiming.caseOutDuration, travel: travel)
        #expect(gone.x == travel)
        #expect(gone.rotation == HeroTiming.caseOutRotation)
        #expect(abs(gone.opacity - HeroTiming.caseOutOpacity) < 0.0001)
        let midway = CaseChoreography.outgoing(elapsed: HeroTiming.caseOutDuration / 2, travel: travel)
        #expect(midway.x > 0 && midway.x < travel)
    }

    @Test func theIncomingCaseWaitsThenOvershootsAndSettles() {
        let waiting = CaseChoreography.incoming(elapsed: HeroTiming.caseInDelay / 2, travel: travel)
        #expect(waiting.x == travel)
        #expect(waiting.rotation == HeroTiming.caseInRotation)
        let overshoot = CaseChoreography.incoming(
            elapsed: HeroTiming.caseInDelay + HeroTiming.caseInDuration * 0.62,
            travel: travel
        )
        #expect(abs(overshoot.x - -14) < 0.01)
        #expect(abs(overshoot.rotation - -2.5) < 0.01)
        let rebound = CaseChoreography.incoming(
            elapsed: HeroTiming.caseInDelay + HeroTiming.caseInDuration * 0.84,
            travel: travel
        )
        #expect(abs(rebound.x - 4) < 0.01)
        let settled = CaseChoreography.incoming(
            elapsed: HeroTiming.caseInDelay + HeroTiming.caseInDuration,
            travel: travel
        )
        #expect(abs(settled.x) < 0.01)
        #expect(abs(settled.rotation) < 0.01)
        #expect(CaseChoreography.isSettled(elapsed: HeroTiming.caseInDelay + HeroTiming.caseInDuration))
        #expect(!CaseChoreography.isSettled(elapsed: HeroTiming.caseInDelay))
    }

    @Test func reduceMotionFadesInPlace() {
        let out = CaseChoreography.outgoing(elapsed: HeroTiming.reducedOut / 2, travel: travel, reduceMotion: true)
        #expect(out.x == 0)
        #expect(abs(out.opacity - 0.5) < 0.0001)
        let incoming = CaseChoreography.incoming(elapsed: HeroTiming.reducedIn, travel: travel, reduceMotion: true)
        #expect(incoming == .rest)
        #expect(CaseChoreography.isSettled(elapsed: HeroTiming.reducedIn, reduceMotion: true))
    }
}
