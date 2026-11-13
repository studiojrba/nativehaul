import Foundation
@testable import nativehaul
import Testing

/// Spec §3.7, ADR 0058: the prompt bar follows the focused screen, row and overlay, and the carousel only advances by
/// itself while focus rests on the hero.
struct CouchPromptsTests {
    private let context = CouchFixtures.homeContext()

    @Test func theHeroOffersKeepPlayingAboutAndSwitchGame() {
        let bar = CouchPrompts.bar(for: CouchFocusState(), context: context, heroPlayLabel: "Keep playing")
        #expect(bar.leading.map(\.label) == ["Keep playing", "About", "Switch game"])
        #expect(bar.trailing.map(\.label) == ["Desktop", "Settings"])
    }

    @Test func tilesArrowsAndOverlaysHaveTheirOwnPrompts() {
        var state = CouchFocusState()
        state.home.row = 0
        state.home.columns = [0, 0]
        #expect(CouchPrompts.bar(for: state, context: context).leading.map(\.label)
            == ["Play", "About", "Switch game", "Jump letter"])
        state.home.columns = [10, 0]
        #expect(CouchPrompts.bar(for: state, context: context).leading.first?.label == "Scroll")
        state.overlay = .paused(.resume)
        #expect(CouchPrompts.bar(for: state, context: context).isEmpty)
        state.overlay = .message("No")
        #expect(CouchPrompts.bar(for: state, context: context).leading.map(\.label) == ["OK"])
    }

    @Test func detailShowsPlayAndBack() {
        let state = CouchFocusState(screen: .detail)
        let bar = CouchPrompts.bar(for: state, context: CouchContext(detailActions: [.play, .favorite]))
        #expect(bar.leading.map(\.label) == ["Play", "Back"])
        #expect(bar.leading.first?.buttons == [.select])
        #expect(bar.leading.last?.buttons == [.back])
    }

    @Test func autoAdvanceOnlyWhileFocusRestsOnTheHero() {
        var state = CouchFocusState()
        #expect(CouchAutoAdvance.isEligible(state, heroCount: 3))
        #expect(!CouchAutoAdvance.isEligible(state, heroCount: 1))
        state.home.row = 0
        #expect(!CouchAutoAdvance.isEligible(state, heroCount: 3))
        state.home.row = CouchHomeFocus.heroArrowsRow
        #expect(!CouchAutoAdvance.isEligible(state, heroCount: 3))
        state.home.row = CouchHomeFocus.heroRow
        state.area = .nav
        #expect(!CouchAutoAdvance.isEligible(state, heroCount: 3))
        state.area = .content
        state.overlay = .launching(UUID())
        #expect(!CouchAutoAdvance.isEligible(state, heroCount: 3))
        state.overlay = .none
        state.screen = .library
        #expect(!CouchAutoAdvance.isEligible(state, heroCount: 3))
    }
}
