import Foundation
@testable import Playrite
import Testing

/// ADR 0035: hero rotation rules.
@MainActor
struct HeroCarouselTests {
    private func carousel(_ count: Int) -> HeroCarousel {
        let carousel = HeroCarousel()
        carousel.update(count: count)
        return carousel
    }

    @Test func advancesAndWraps() {
        let rotation = carousel(3)
        rotation.tick()
        rotation.tick()
        #expect(rotation.index == 2)
        rotation.tick()
        #expect(rotation.index == 0)
    }

    @Test func hoverPauses() {
        let rotation = carousel(3)
        rotation.isHovered = true
        rotation.tick()
        #expect(rotation.index == 0)
    }

    @Test func navigatingWaitsAFullIntervalBeforeTheNextAdvance() {
        let rotation = carousel(3)
        rotation.step(by: -1)
        #expect(rotation.index == 2)
        rotation.tick()
        #expect(rotation.index == 2)
        rotation.tick()
        #expect(rotation.index == 0)
        rotation.select(1)
        rotation.tick()
        #expect(rotation.index == 1)
    }

    @Test func oneHeroNeverMovesAndShrinkingKeepsTheIndexInRange() {
        let single = carousel(1)
        single.tick()
        #expect(single.index == 0)
        let rotation = carousel(5)
        rotation.select(4)
        rotation.update(count: 2)
        #expect(rotation.index == 1)
    }

    @Test func theIntervalIsAboutSixSeconds() {
        #expect(HeroCarousel.interval == .seconds(6))
    }
}
