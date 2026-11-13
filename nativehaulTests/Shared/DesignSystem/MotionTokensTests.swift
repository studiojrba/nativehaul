@testable import nativehaul
import Testing

/// Spec §2.8, §4.2, §4.4: the motion constants and the small formulas built on them.
struct MotionTokensTests {
    @Test func theHouseDurationsAreTheSpecs() {
        let durations = [
            Motion.Duration.quick, Motion.Duration.press, Motion.Duration.standard,
            Motion.Duration.rise, Motion.Duration.slow, Motion.Duration.turn,
        ]
        #expect(durations == [0.3, 0.38, 0.5, 0.7, 1.0, 1.1])
        #expect(HeroTiming.textOut == 0.35)
        #expect(HeroTiming.interval == 7)
    }

    @Test func typingDotsGrowWithTheMessageAndCap() {
        #expect(TypingTiming.dotsDuration(length: 0) == 0.52)
        #expect(abs(TypingTiming.dotsDuration(length: 50) - 0.82) < 0.0001)
        #expect(TypingTiming.dotsDuration(length: 10000) == 1.02)
    }

    @Test func punctuationPausesTheReveal() {
        #expect(TypingTiming.delay(after: "a") == 0.016)
        #expect(abs(TypingTiming.delay(after: ".") - 0.156) < 0.0001)
        #expect(abs(TypingTiming.delay(after: "?") - 0.156) < 0.0001)
        #expect(abs(TypingTiming.delay(after: ",") - 0.096) < 0.0001)
    }

    @Test func shelfPagingEasesOutCubically() {
        #expect(ShelfPhysics.pageEasing(0) == 0)
        #expect(ShelfPhysics.pageEasing(1) == 1)
        #expect(ShelfPhysics.pageEasing(0.5) == 0.875)
        #expect(ShelfPhysics.pageEasing(2) == 1)
    }

    @Test func frictionIsFrameRateIndependent() {
        #expect(abs(ShelfPhysics.friction(over: 0.016) - 0.95) < 0.0001)
        #expect(abs(ShelfPhysics.friction(over: 0.032) - 0.9025) < 0.0001)
        #expect(ShelfPhysics.smoothedVelocity(previous: 1, sample: 2) == 1.8)
    }
}
