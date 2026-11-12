@testable import nativehaul
import Testing

/// ADR 0052: focus moves never wrap or leave an empty selection; LT/RT jump between first letters.
struct TVNavigatorTests {
    private let counts = [3, 5]

    @Test func shelvesMoveAlongARowAndBetweenRows() {
        var focus = TVFocus()
        focus = TVNavigator.move(focus, .left, shelfCounts: counts, layout: .shelf, columns: 1)
        #expect(focus == TVFocus(shelf: 0, item: 0))
        focus = TVNavigator.move(TVFocus(shelf: 0, item: 2), .right, shelfCounts: counts, layout: .shelf, columns: 1)
        #expect(focus == TVFocus(shelf: 0, item: 2))
        focus = TVNavigator.move(TVFocus(shelf: 1, item: 4), .up, shelfCounts: counts, layout: .shelf, columns: 1)
        #expect(focus == TVFocus(shelf: 0, item: 2))
        focus = TVNavigator.move(focus, .down, shelfCounts: counts, layout: .shelf, columns: 1)
        #expect(focus == TVFocus(shelf: 1, item: 2))
    }

    @Test func theGridMovesByRowsInsideOneShelf() {
        let start = TVFocus(shelf: 1, item: 1)
        #expect(TVNavigator.move(start, .down, shelfCounts: counts, layout: .grid, columns: 3).item == 4)
        #expect(TVNavigator.move(start, .up, shelfCounts: counts, layout: .grid, columns: 3).item == 1)
        #expect(TVNavigator.move(TVFocus(shelf: 1, item: 3), .down, shelfCounts: counts, layout: .grid, columns: 3)
            .item == 3)
    }

    @Test func shoulderButtonsChangeShelfFromItsFirstGame() {
        let focus = TVNavigator.changingShelf(TVFocus(shelf: 0, item: 2), by: 1, shelfCounts: counts, keepItem: false)
        #expect(focus == TVFocus(shelf: 1, item: 0))
        #expect(TVNavigator.changingShelf(focus, by: 1, shelfCounts: counts, keepItem: false) == focus)
    }

    @Test func triggersJumpBetweenFirstLetters() {
        let titles = ["Animal", "Astro", "Bayonetta", "Celeste", "Cuphead", "Élan"]
        #expect(TVNavigator.nextLetter(from: 0, titles: titles) == 2)
        #expect(TVNavigator.nextLetter(from: 3, titles: titles) == 5)
        #expect(TVNavigator.nextLetter(from: 5, titles: titles) == nil)
        #expect(TVNavigator.previousLetter(from: 4, titles: titles) == 2)
        #expect(TVNavigator.previousLetter(from: 1, titles: titles) == nil)
        #expect(TVNavigator.initial(of: "Élan") == "E")
        #expect(TVNavigator.initial(of: "007") == "#")
    }
}
