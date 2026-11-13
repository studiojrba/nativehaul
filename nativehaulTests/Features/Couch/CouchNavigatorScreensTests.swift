import Foundation
@testable import nativehaul
import Testing

/// ADR 0058: the mirrored screens under the couch model — the nav column, Library's reading-order grid, Detail, Builds
/// and Settings, the buttons that work everywhere, and the overlays.
struct CouchNavigatorScreensTests {
    @Test func theNavColumnMovesOpensAScreenAndHandsFocusBack() {
        var state = CouchFocusState()
        let context = CouchFixtures.homeContext()
        _ = CouchNavigator.reduce(&state, .move(.down), context: context)
        _ = CouchNavigator.reduce(&state, .move(.left), context: context)
        #expect(CouchNavigator.reduce(&state, .move(.up), context: context).isEmpty)
        _ = CouchNavigator.reduce(&state, .move(.down), context: context)
        #expect(state.navIndex == 1)
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.sound(.confirm)])
        #expect(state.screen == .library)
        #expect(state.area == .content)
        _ = CouchNavigator.focusNav(&state)
        #expect(state.navIndex == 1)
        #expect(CouchNavigator.reduce(&state, .back, context: context) == [.sound(.back)])
        #expect(state.area == .content)
    }

    @Test func theLibraryGridMovesInReadingOrder() {
        let context = CouchContext(library: CouchFixtures.items(count: 7), libraryColumns: 3)
        var state = CouchFocusState(screen: .library)
        _ = CouchNavigator.reduce(&state, .move(.right), context: context)
        _ = CouchNavigator.reduce(&state, .move(.right), context: context)
        _ = CouchNavigator.reduce(&state, .move(.right), context: context)
        #expect(state.libraryIndex == 3)
        _ = CouchNavigator.reduce(&state, .move(.down), context: context)
        #expect(state.libraryIndex == 6)
        _ = CouchNavigator.reduce(&state, .move(.up), context: context)
        #expect(state.libraryIndex == 3)
        #expect(CouchNavigator.reduce(&state, .move(.left), context: context) == [.sound(.navigate)])
        #expect(state.area == .nav)
    }

    @Test func downFromAboveAShortLastRowLandsOnTheLastTile() {
        #expect(CouchNavigator.gridTarget(from: 5, .down, columns: 3, count: 7) == 6)
        #expect(CouchNavigator.gridTarget(from: 6, .down, columns: 3, count: 7) == 6)
        #expect(CouchNavigator.gridTarget(from: 1, .up, columns: 3, count: 7) == 1)
        #expect(CouchNavigator.gridTarget(from: 2, .right, columns: 3, count: 7) == 3)
    }

    @Test func libraryTilesPlayAndOpenAndBGoesHome() {
        let items = CouchFixtures.items(count: 4)
        let context = CouchContext(library: items, libraryColumns: 2)
        var state = CouchFocusState(screen: .library, libraryIndex: 1)
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.play(items[1].id)])
        #expect(CouchNavigator.reduce(&state, .details, context: context) == [
            .sound(.confirm),
            .openDetails(items[1].id),
        ])
        #expect(CouchNavigator.reduce(&state, .back, context: context) == [.sound(.back)])
        #expect(state.screen == .home)
    }

    @Test func detailMovesBetweenItsButtonsAndBGoesBackWhereItCameFrom() {
        let gameID = UUID()
        var state = CouchFocusState(screen: .library)
        CouchNavigator.openDetail(&state, gameID: gameID)
        let context = CouchContext(detailActions: [.play, .favorite])
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.play(gameID)])
        _ = CouchNavigator.reduce(&state, .move(.right), context: context)
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.sound(.confirm), .toggleFavorite])
        _ = CouchNavigator.reduce(&state, .move(.left), context: context)
        _ = CouchNavigator.reduce(&state, .move(.left), context: context)
        #expect(state.area == .nav)
        state.area = .content
        #expect(CouchNavigator.reduce(&state, .back, context: context) == [.sound(.back)])
        #expect(state.screen == .library)
    }

    @Test func buildsMoveUpAndDownAndAOpensTheBuild() {
        let context = CouchContext(buildCount: 3)
        var state = CouchFocusState(screen: .builds)
        #expect(CouchNavigator.reduce(&state, .move(.up), context: context).isEmpty)
        #expect(CouchNavigator.reduce(&state, .move(.down), context: context) == [.sound(.navigate), .selectBuild(1)])
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.sound(.confirm), .openBuild(1)])
        _ = CouchNavigator.reduce(&state, .move(.left), context: context)
        #expect(state.area == .nav)
    }

    @Test func settingsAdjustInPlaceToggleAndExit() {
        let context = CouchContext()
        var state = CouchFocusState(screen: .settings)
        #expect(CouchNavigator.reduce(&state, .move(.right), context: context)
            == [.sound(.navigate), .setting(.appearance, .increase)])
        _ = CouchNavigator.reduce(&state, .move(.down), context: context)
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [
            .sound(.confirm),
            .setting(.music, .activate),
        ])
        #expect(CouchNavigator.reduce(&state, .move(.left), context: context) == [.sound(.navigate)])
        #expect(state.area == .nav)
        state.area = .content
        _ = CouchNavigator.reduce(&state, .move(.down), context: context)
        #expect(CouchNavigator.reduce(&state, .move(.left), context: context)
            == [.sound(.navigate), .setting(.musicVolume, .decrease)])
        state.settingsIndex = CouchSettingsRow.allCases.count - 1
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.sound(.back), .exitToDesktop])
    }

    @Test func viewLeavesCouchMenuOpensSettingsAndHomeGoesHome() {
        let context = CouchContext()
        var state = CouchFocusState(screen: .builds)
        #expect(CouchNavigator.reduce(&state, .view, context: context) == [.sound(.back), .exitToDesktop])
        _ = CouchNavigator.reduce(&state, .menu, context: context)
        #expect(state.screen == .settings)
        #expect(CouchNavigator.reduce(&state, .home, context: context) == [.sound(.back)])
        #expect(state.screen == .home)
    }

    @Test func pausedOverlayTogglesOnAnyDirectionAndResumesOrCloses() {
        let context = CouchContext()
        var state = CouchFocusState(overlay: .paused(.resume))
        _ = CouchNavigator.reduce(&state, .move(.up), context: context)
        #expect(state.overlay == .paused(.close))
        _ = CouchNavigator.reduce(&state, .move(.left), context: context)
        #expect(state.overlay == .paused(.resume))
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.sound(.confirm), .resumeGame])
        #expect(state.overlay == .none)
        state.overlay = .paused(.close)
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.sound(.confirm), .closeGame])
        #expect(state.overlay == .closing)
        #expect(CouchNavigator.reduce(&state, .select, context: context).isEmpty)
    }

    @Test func bOrHomeOnThePausedOverlayResumes() {
        let context = CouchContext()
        var state = CouchFocusState(overlay: .paused(.close))
        #expect(CouchNavigator.reduce(&state, .back, context: context) == [.sound(.confirm), .resumeGame])
        state.overlay = .paused(.close)
        #expect(CouchNavigator.reduce(&state, .home, context: context) == [.sound(.confirm), .resumeGame])
    }

    @Test func theForceQuitOfferDefaultsToWaitingAndBKeepsWaiting() {
        let context = CouchContext()
        var state = CouchFocusState(overlay: .forceQuitOffer(.keepWaiting))
        #expect(CouchNavigator.reduce(&state, .back, context: context) == [.sound(.back), .keepWaiting])
        #expect(state.overlay == .closing)
        state.overlay = .forceQuitOffer(.keepWaiting)
        _ = CouchNavigator.reduce(&state, .move(.right), context: context)
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.sound(.confirm), .forceQuitGame])
        #expect(state.overlay == .closing)
    }

    @Test func theLaunchPhaseOnlyListensForBAndMessagesCloseOnAOrB() {
        let context = CouchContext()
        var state = CouchFocusState(overlay: .launching(UUID()))
        #expect(CouchNavigator.reduce(&state, .select, context: context).isEmpty)
        #expect(CouchNavigator.reduce(&state, .back, context: context) == [.sound(.back), .dismissLaunch])
        #expect(state.overlay == .none)
        state.overlay = .message("It didn't start.")
        #expect(CouchNavigator.reduce(&state, .move(.left), context: context).isEmpty)
        #expect(CouchNavigator.reduce(&state, .select, context: context) == [.sound(.confirm)])
        #expect(state.overlay == .none)
    }
}
