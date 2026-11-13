import Foundation
@testable import nativehaul
import Testing

/// Spec §4.1: the carousel's two indices, its loop, and its auto-advance rules.
@MainActor
struct HeroCarouselTests {
    /// A sleep that never finishes on its own (until its task is cancelled), so tests drive the phases by hand.
    private static let suspended: @Sendable (Double) async -> Void = { _ in
        try? await Task.sleep(for: .seconds(3600))
    }

    private func carousel(_ count: Int) -> HeroCarousel {
        let carousel = HeroCarousel(sleep: Self.suspended)
        carousel.update(count: count)
        return carousel
    }

    @Test func aSwitchMovesTheTargetAtOnceAndTheTextOnlyAfterItFades() {
        let hero = carousel(3)
        hero.next()
        #expect(hero.index == 1)
        #expect(hero.shown == 0)
        #expect(!hero.isTextVisible)
        #expect(hero.leaving == 0)
        hero.finishTextOut(turn: hero.turn)
        #expect(hero.shown == 1)
        #expect(hero.isTextVisible)
        #expect(hero.leaving == 0)
        hero.finishCase(turn: hero.turn)
        #expect(hero.leaving == nil)
    }

    @Test func theCarouselLoopsBothWays() {
        let hero = carousel(3)
        hero.previous()
        #expect(hero.index == 2)
        hero.next()
        #expect(hero.index == 0)
        hero.go(to: 5)
        #expect(hero.index == 2)
    }

    @Test func switchingToTheCurrentSlideDoesNothing() {
        let hero = carousel(3)
        hero.go(to: 0)
        #expect(hero.turn == 0)
        #expect(hero.isTextVisible)
    }

    @Test func aStalePhaseFromAnEarlierSwitchIsIgnored() {
        let hero = carousel(3)
        hero.next()
        let first = hero.turn
        hero.next()
        hero.finishTextOut(turn: first)
        #expect(!hero.isTextVisible)
        #expect(hero.shown == 0)
        hero.finishTextOut(turn: hero.turn)
        #expect(hero.shown == 2)
    }

    @Test func anySwitchOrHoverRestartsTheAutoAdvanceClock() {
        let hero = carousel(3)
        let resting = hero.autoAdvanceKey
        hero.next()
        #expect(hero.autoAdvanceKey != resting)
        let afterSwitch = hero.autoAdvanceKey
        hero.isHovered = true
        #expect(hero.autoAdvanceKey != afterSwitch)
    }

    @Test func autoAdvanceWaitsOneIntervalThenMoves() async {
        let waited = WaitLog()
        let hero = HeroCarousel(sleep: { seconds in await waited.record(seconds) })
        hero.update(count: 2)
        await hero.runAutoAdvance()
        #expect(hero.index == 1)
        #expect(await waited.values.first == HeroTiming.interval)
    }

    @Test func hoverAndASingleSlideNeverAutoAdvance() async {
        let hovered = HeroCarousel(sleep: { _ in })
        hovered.update(count: 3)
        hovered.isHovered = true
        await hovered.runAutoAdvance()
        #expect(hovered.index == 0)
        let single = HeroCarousel(sleep: { _ in })
        single.update(count: 1)
        await single.runAutoAdvance()
        #expect(single.index == 0)
    }

    @Test func shrinkingPastTheCurrentSlideResets() {
        let hero = carousel(4)
        hero.go(to: 3)
        hero.update(count: 2)
        #expect(hero.index == 0)
        #expect(hero.shown == 0)
        #expect(hero.leaving == nil)
        #expect(hero.isTextVisible)
    }

    @Test func theTimingsMatchTheSpec() {
        #expect(HeroTiming.textOut == 0.35)
        #expect(HeroTiming.textIn == 0.45)
        #expect(HeroTiming.wash == 0.8)
        #expect(HeroTiming.caseDone == 1.3)
        #expect(HeroTiming.interval == 7)
    }
}
