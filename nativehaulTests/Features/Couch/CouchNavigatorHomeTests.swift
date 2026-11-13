import Foundation
@testable import nativehaul
import Testing

/// Spec §3.7, implemented exactly: rows −2 (hero arrows), −1 (hero), 0…n (shelves); per-shelf remembered columns and
/// scroll starts; arrows as real focus stops; paging by V; settling off an arrow; LB/RB, LT/RT, A, X and B on Home.
struct CouchNavigatorHomeTests {
    private let context = CouchFixtures.homeContext()

    private func send(_ inputs: CouchInput..., to state: inout CouchFocusState) -> [CouchEffect] {
        var effects: [CouchEffect] = []
        for input in inputs {
            effects = CouchNavigator.reduce(&state, input, context: context)
        }
        return effects
    }

    @Test func homeStartsOnTheHeroAndUpReachesTheArrowRowThenStops() {
        var state = CouchFocusState()
        #expect(state.home.row == CouchHomeFocus.heroRow)
        #expect(send(.move(.up), to: &state) == [.sound(.navigate)])
        #expect(state.home.row == CouchHomeFocus.heroArrowsRow)
        #expect(send(.move(.up), to: &state).isEmpty)
        #expect(state.home.row == CouchHomeFocus.heroArrowsRow)
    }

    @Test func downWalksTheShelvesAndStopsAtTheLast() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.down), to: &state)
        #expect(state.home.row == 1)
        #expect(send(.move(.down), to: &state).isEmpty)
        #expect(state.home.row == 1)
    }

    @Test func theHeroSwitchesGamesWithLeftRightAndTheShoulders() {
        var state = CouchFocusState()
        #expect(send(.move(.left), to: &state) == [.sound(.navigate), .previousHero])
        #expect(send(.move(.right), to: &state) == [.sound(.navigate), .nextHero])
        _ = send(.move(.down), to: &state)
        #expect(send(.previousGame, to: &state) == [.sound(.navigate), .previousHero])
        #expect(send(.nextGame, to: &state) == [.sound(.navigate), .nextHero])
    }

    @Test func aOnTheHeroPlaysAndXOpensItsDetails() {
        var state = CouchFocusState()
        #expect(send(.select, to: &state) == [.playHero])
        #expect(send(.details, to: &state) == [.sound(.confirm), .openHeroDetails])
        #expect(send(.previousLetter, to: &state).isEmpty)
    }

    @Test func theArrowRowPicksAnArrowAndAPagesTheHero() {
        var state = CouchFocusState()
        _ = send(.move(.up), to: &state)
        #expect(state.home.heroArrow == .right)
        #expect(send(.select, to: &state) == [.sound(.confirm), .nextHero])
        #expect(send(.move(.left), to: &state) == [.sound(.navigate)])
        #expect(state.home.heroArrow == .left)
        #expect(send(.select, to: &state) == [.sound(.confirm), .previousHero])
        #expect(send(.move(.right), to: &state) == [.sound(.navigate)])
        #expect(state.home.heroArrow == .right)
    }

    @Test func leftPastTheLeftHeroArrowReachesTheNavColumn() {
        var state = CouchFocusState()
        _ = send(.move(.up), .move(.left), to: &state)
        #expect(send(.move(.left), to: &state) == [.sound(.navigate)])
        #expect(state.area == .nav)
    }

    @Test func rightMovesTileByTileThenReachesTheRightArrow() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.right), .move(.right), .move(.right), to: &state)
        #expect(state.home.columns[0] == 3)
        #expect(state.home.starts[0] == 0)
        #expect(send(.move(.right), to: &state) == [.sound(.navigate)])
        #expect(state.home.columns[0] == 10)
    }

    @Test func aOnTheRightArrowPagesByVAndStaysUntilTheEnd() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.right), .move(.right), .move(.right), .move(.right), to: &state)
        #expect(send(.select, to: &state) == [.sound(.confirm)])
        #expect(state.home.starts[0] == 4)
        #expect(state.home.columns[0] == 10)
        _ = send(.select, to: &state)
        #expect(state.home.starts[0] == 6)
        #expect(state.home.columns[0] == 9)
    }

    @Test func rightOnTheRightArrowPagesAndLandsOnTheFirstNewTile() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.right), .move(.right), .move(.right), .move(.right), to: &state)
        _ = send(.move(.right), to: &state)
        #expect(state.home.starts[0] == 4)
        #expect(state.home.columns[0] == 4)
    }

    @Test func leftFromTheRightArrowReturnsToTheLastVisibleTile() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.right), .move(.right), .move(.right), .move(.right), .move(.left), to: &state)
        #expect(state.home.columns[0] == 3)
    }

    @Test func theLeftArrowIsAFocusStopWhenTilesHideBehind() {
        var state = CouchFocusState()
        _ = send(.move(.down), to: &state)
        state.home.starts[0] = 4
        state.home.columns[0] = 4
        _ = send(.move(.left), to: &state)
        #expect(state.home.columns[0] == CouchHomeFocus.leftArrowColumn)
        _ = send(.move(.right), to: &state)
        #expect(state.home.columns[0] == 4)
        _ = send(.move(.left), .move(.left), to: &state)
        #expect(state.home.starts[0] == 0)
        #expect(state.home.columns[0] == 3)
    }

    @Test func aOnTheLeftArrowPagesBackAndLandsOnTheFirstTileAtTheStart() {
        var state = CouchFocusState()
        _ = send(.move(.down), to: &state)
        state.home.starts[0] = 4
        state.home.columns[0] = CouchHomeFocus.leftArrowColumn
        _ = send(.select, to: &state)
        #expect(state.home.starts[0] == 0)
        #expect(state.home.columns[0] == 0)
    }

    @Test func leavingAShelfOnAnArrowSettlesOnTheNearestVisibleTile() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.right), .move(.right), .move(.right), .move(.right), to: &state)
        _ = send(.move(.down), to: &state)
        #expect(state.home.columns[0] == 3)
        _ = send(.move(.up), to: &state)
        state.home.starts[0] = 4
        state.home.columns[0] = CouchHomeFocus.leftArrowColumn
        _ = send(.move(.up), to: &state)
        #expect(state.home.columns[0] == 4)
    }

    @Test func eachShelfRemembersItsColumn() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.right), .move(.right), .move(.down), .move(.right), .move(.up), to: &state)
        #expect(state.home.row == 0)
        #expect(state.home.columns == [2, 1])
    }

    @Test func aOnATilePlaysItAndXOpensItsDetails() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.right), to: &state)
        let tile = context.shelves[0].items[1].id
        #expect(send(.select, to: &state) == [.play(tile)])
        #expect(send(.details, to: &state) == [.sound(.confirm), .openDetails(tile)])
    }

    @Test func leftFromTheFirstTileReachesTheNavColumn() {
        var state = CouchFocusState()
        _ = send(.move(.down), to: &state)
        #expect(send(.move(.left), to: &state) == [.sound(.navigate)])
        #expect(state.area == .nav)
        #expect(state.navIndex == 0)
    }

    @Test func rightOnAShortShelfStopsAtItsLastTile() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.down), .move(.right), .move(.right), to: &state)
        #expect(state.home.columns[1] == 2)
        #expect(send(.move(.right), to: &state).isEmpty)
    }

    @Test func bOnHomeSaysYoureHomeAndHomeSaysAlreadyHome() {
        var state = CouchFocusState()
        #expect(send(.back, to: &state) == [.sound(.back), .toast(.youreHome)])
        #expect(send(.home, to: &state) == [.toast(.alreadyHome)])
        #expect(state.screen == .home)
    }

    @Test func triggersJumpByLetterWithALetterToast() {
        let shelf = CouchShelf(title: "Everything, A–Z", items: CouchFixtures.items(
            ["Astral", "Axiom", "Bayonetta", "The Banner", "Celeste", "Dredge"]
        ))
        let context = CouchContext(heroCount: 2, shelves: [shelf], visibleCount: 4)
        var state = CouchFocusState()
        _ = CouchNavigator.reduce(&state, .move(.down), context: context)
        let effects = CouchNavigator.reduce(&state, .nextLetter, context: context)
        #expect(effects == [.sound(.navigate), .toast(.letter("B"))])
        #expect(state.home.columns[0] == 2)
        _ = CouchNavigator.reduce(&state, .nextLetter, context: context)
        #expect(state.home.columns[0] == 4)
        #expect(state.home.starts[0] == 1)
        _ = CouchNavigator.reduce(&state, .previousLetter, context: context)
        #expect(state.home.columns[0] == 2)
    }

    @Test func triggersDoNothingOnAnArrow() {
        var state = CouchFocusState()
        _ = send(.move(.down), .move(.right), .move(.right), .move(.right), .move(.right), to: &state)
        #expect(send(.nextLetter, to: &state).isEmpty)
    }

    @Test func aSingleGameHeroHasNoArrowRowAndNoSwitching() {
        let context = CouchFixtures.homeContext(heroCount: 1)
        var state = CouchFocusState()
        #expect(CouchNavigator.reduce(&state, .move(.up), context: context).isEmpty)
        #expect(CouchNavigator.reduce(&state, .nextGame, context: context).isEmpty)
        #expect(CouchNavigator.reduce(&state, .move(.left), context: context) == [.sound(.navigate)])
        #expect(state.area == .nav)
    }
}
