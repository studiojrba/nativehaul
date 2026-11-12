import Foundation

/// Pure focus rules for TV mode (ADR 0052). Moves never wrap and never leave an empty selection.
enum TVNavigator {
    /// Moves the focus one step. In shelves, left/right move along a shelf and up/down change shelf; in the grid,
    /// up/down move a row within the current shelf.
    static func move(
        _ focus: TVFocus,
        _ direction: TVDirection,
        shelfCounts: [Int],
        layout: TVLayout,
        columns: Int
    ) -> TVFocus {
        guard shelfCounts.indices.contains(focus.shelf) else { return TVFocus() }
        let count = shelfCounts[focus.shelf]
        var next = focus
        switch (layout, direction) {
        case (_, .left):
            next.item = max(focus.item - 1, 0)
        case (_, .right):
            next.item = min(focus.item + 1, count - 1)
        case (.shelf, .up):
            next = changingShelf(focus, by: -1, shelfCounts: shelfCounts, keepItem: true)
        case (.shelf, .down):
            next = changingShelf(focus, by: 1, shelfCounts: shelfCounts, keepItem: true)
        case (.grid, .up):
            let row = max(columns, DesignTokens.TVMode.minimumColumns)
            if focus.item - row >= 0 {
                next.item = focus.item - row
            }
        case (.grid, .down):
            let row = max(columns, DesignTokens.TVMode.minimumColumns)
            if focus.item + row < count {
                next.item = focus.item + row
            }
        }
        return next
    }

    /// Switches shelf (LB/RB, or up/down in shelves). LB/RB start the new shelf at its first game.
    static func changingShelf(_ focus: TVFocus, by offset: Int, shelfCounts: [Int], keepItem: Bool) -> TVFocus {
        guard !shelfCounts.isEmpty else { return TVFocus() }
        let shelf = min(max(focus.shelf + offset, 0), shelfCounts.count - 1)
        guard shelf != focus.shelf else { return focus }
        let item = keepItem ? min(focus.item, shelfCounts[shelf] - 1) : 0
        return TVFocus(shelf: shelf, item: item)
    }

    /// The start of the next run of titles with a different first letter (LT/RT), or `nil` at the end.
    static func nextLetter(from index: Int, titles: [String]) -> Int? {
        guard titles.indices.contains(index) else { return nil }
        let current = initial(of: titles[index])
        return titles.indices.first { $0 > index && initial(of: titles[$0]) != current }
    }

    /// The start of the previous run of titles with a different first letter, or `nil` at the start.
    static func previousLetter(from index: Int, titles: [String]) -> Int? {
        guard titles.indices.contains(index) else { return nil }
        let runStart = start(ofRunAt: index, titles: titles)
        guard runStart > 0 else { return nil }
        return start(ofRunAt: runStart - 1, titles: titles)
    }

    /// A title's first letter, uppercased and without accents; digits and symbols share "#".
    static func initial(of title: String) -> String {
        let folded = title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil).uppercased()
        guard let first = folded.first(where: { !$0.isWhitespace }) else { return "#" }
        return first.isLetter ? String(first) : "#"
    }

    private static func start(ofRunAt index: Int, titles: [String]) -> Int {
        let letter = initial(of: titles[index])
        var start = index
        while start > 0, initial(of: titles[start - 1]) == letter {
            start -= 1
        }
        return start
    }
}
