import Foundation

/// Couch Home (spec §3.7, implemented exactly): the hero's arrow pair (row −2), the hero (−1) and the shelves (0…n),
/// with per-shelf remembered columns and scroll starts, arrows as real focus stops, paging by V tiles, LB/RB from
/// anywhere, LT/RT letter jumps, A to play, X for details and B for "You're home". Left from a shelf's first tile (or
/// past the hero's left arrow) reaches the nav column.
extension CouchNavigator {
    static func reduceHome(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        context: CouchContext
    ) -> [CouchEffect] {
        state.home.fit(shelfCount: context.shelves.count)
        switch input {
        case .previousGame:
            return context.heroCount > 1 ? [.sound(.navigate), .previousHero] : []
        case .nextGame:
            return context.heroCount > 1 ? [.sound(.navigate), .nextHero] : []
        case .back:
            return [.sound(.back), .toast(.youreHome)]
        case .move(.up):
            return moveRow(&state, to: state.home.row - 1, context: context)
        case .move(.down):
            return moveRow(&state, to: state.home.row + 1, context: context)
        default:
            break
        }
        switch state.home.row {
        case CouchHomeFocus.heroArrowsRow:
            return reduceHeroArrows(&state, input)
        case CouchHomeFocus.heroRow:
            return reduceHero(&state, input, context: context)
        default:
            return reduceShelf(&state, input, context: context)
        }
    }

    /// The topmost row Home has: the arrows when the hero can switch, else the hero, else the first shelf.
    static func topRow(_ context: CouchContext) -> Int {
        if context.heroCount > 1 {
            return CouchHomeFocus.heroArrowsRow
        }
        return context.heroCount == 1 ? CouchHomeFocus.heroRow : 0
    }

    /// The first visible tile of shelf `row` (never past the last full screenful).
    static func start(of row: Int, state: CouchFocusState, context: CouchContext) -> Int {
        let count = context.shelves[row].items.count
        return min(state.home.starts[row], max(0, count - context.visibleCount))
    }

    // MARK: Rows

    private static func moveRow(
        _ state: inout CouchFocusState,
        to target: Int,
        context: CouchContext
    ) -> [CouchEffect] {
        let bottom = context.shelves.count - 1
        let top = topRow(context)
        guard bottom >= top else { return [] }
        let clamped = min(max(target, top), bottom)
        guard clamped != state.home.row else { return [] }
        settle(&state, row: state.home.row, context: context)
        state.home.row = clamped
        return [.sound(.navigate)]
    }

    /// Arrow focus doesn't survive leaving a shelf: it falls back to the nearest visible tile.
    private static func settle(_ state: inout CouchFocusState, row: Int, context: CouchContext) {
        guard row >= 0, context.shelves.indices.contains(row) else { return }
        let count = context.shelves[row].items.count
        let first = start(of: row, state: state, context: context)
        if state.home.columns[row] < 0 {
            state.home.columns[row] = first
        } else if state.home.columns[row] >= count {
            state.home.columns[row] = min(count - 1, first + context.visibleCount - 1)
        }
    }

    private static func reduceHeroArrows(_ state: inout CouchFocusState, _ input: CouchInput) -> [CouchEffect] {
        switch input {
        case .move(.left):
            guard state.home.heroArrow == .right else { return focusNav(&state) }
            state.home.heroArrow = .left
            return [.sound(.navigate)]
        case .move(.right):
            guard state.home.heroArrow == .left else { return [] }
            state.home.heroArrow = .right
            return [.sound(.navigate)]
        case .select:
            return [.sound(.confirm), state.home.heroArrow == .left ? .previousHero : .nextHero]
        default:
            return []
        }
    }

    private static func reduceHero(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        context: CouchContext
    ) -> [CouchEffect] {
        guard context.heroCount > 0 else {
            return input == .move(.left) ? focusNav(&state) : []
        }
        switch input {
        case .move(.left):
            return context.heroCount > 1 ? [.sound(.navigate), .previousHero] : focusNav(&state)
        case .move(.right):
            return context.heroCount > 1 ? [.sound(.navigate), .nextHero] : []
        case .select:
            return [.playHero]
        case .details:
            return [.sound(.confirm), .openHeroDetails]
        default:
            return []
        }
    }

    // MARK: Shelves

    private static func reduceShelf(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        context: CouchContext
    ) -> [CouchEffect] {
        let row = state.home.row
        guard context.shelves.indices.contains(row) else {
            return input == .move(.left) ? focusNav(&state) : []
        }
        let items = context.shelves[row].items
        let column = state.home.columns[row]
        let isOnArrow = column < 0 || column >= items.count
        switch input {
        case .move(.left):
            return shelfLeft(&state, row: row, context: context)
        case .move(.right):
            return shelfRight(&state, row: row, context: context)
        case .select where isOnArrow:
            return pageFromArrow(&state, row: row, context: context)
        case .select:
            return [.play(items[column].id)]
        case .details where !isOnArrow:
            return [.sound(.confirm), .openDetails(items[column].id)]
        case .previousLetter where !isOnArrow, .nextLetter where !isOnArrow:
            let titles = items.map(\.title)
            let target = input == .nextLetter
                ? LetterJump.next(from: column, titles: titles)
                : LetterJump.previous(from: column, titles: titles)
            setColumn(&state, row: row, to: target, context: context)
            return [.sound(.navigate), .toast(.letter(LetterJump.initial(of: titles[target])))]
        default:
            return []
        }
    }

    private static func shelfLeft(_ state: inout CouchFocusState, row: Int, context: CouchContext) -> [CouchEffect] {
        let count = context.shelves[row].items.count
        let column = state.home.columns[row]
        let first = start(of: row, state: state, context: context)
        if column >= count {
            state.home.columns[row] = min(count - 1, first + context.visibleCount - 1)
        } else if column < 0 {
            page(&state, row: row, by: -1, context: context)
            state.home.columns[row] = first - 1
        } else if column == first, first > 0 {
            state.home.columns[row] = CouchHomeFocus.leftArrowColumn
        } else if column == 0 {
            return focusNav(&state)
        } else {
            setColumn(&state, row: row, to: column - 1, context: context)
        }
        return [.sound(.navigate)]
    }

    private static func shelfRight(_ state: inout CouchFocusState, row: Int, context: CouchContext) -> [CouchEffect] {
        let count = context.shelves[row].items.count
        let column = state.home.columns[row]
        let first = start(of: row, state: state, context: context)
        let lastVisible = min(count - 1, first + context.visibleCount - 1)
        if column < 0 {
            state.home.columns[row] = first
        } else if column >= count {
            page(&state, row: row, by: 1, context: context)
            state.home.columns[row] = first + context.visibleCount
        } else if column == lastVisible, first + context.visibleCount < count {
            state.home.columns[row] = count
        } else if column < count - 1 {
            setColumn(&state, row: row, to: column + 1, context: context)
        } else {
            return []
        }
        return [.sound(.navigate)]
    }

    /// A on an arrow pages by a screenful and stays on the arrow, unless that end is now reached.
    private static func pageFromArrow(
        _ state: inout CouchFocusState,
        row: Int,
        context: CouchContext
    ) -> [CouchEffect] {
        let count = context.shelves[row].items.count
        let isLeft = state.home.columns[row] < 0
        let newStart = page(&state, row: row, by: isLeft ? -1 : 1, context: context)
        if isLeft, newStart == 0 {
            state.home.columns[row] = 0
        } else if !isLeft, newStart + context.visibleCount >= count {
            state.home.columns[row] = count - 1
        }
        return [.sound(.confirm)]
    }

    /// Pages shelf `row` by one screenful; returns its new first visible tile.
    @discardableResult
    private static func page(
        _ state: inout CouchFocusState,
        row: Int,
        by direction: Int,
        context: CouchContext
    ) -> Int {
        let count = context.shelves[row].items.count
        let first = start(of: row, state: state, context: context)
        let newStart = max(0, min(max(0, count - context.visibleCount), first + direction * context.visibleCount))
        state.home.starts[row] = newStart
        return newStart
    }

    /// Focuses a tile, scrolling the shelf just enough to keep it fully visible.
    private static func setColumn(_ state: inout CouchFocusState, row: Int, to column: Int, context: CouchContext) {
        let count = context.shelves[row].items.count
        let target = max(0, min(count - 1, column))
        let first = start(of: row, state: state, context: context)
        if target < first {
            state.home.starts[row] = target
        } else if target > first + context.visibleCount - 1 {
            state.home.starts[row] = target - context.visibleCount + 1
        }
        state.home.columns[row] = target
    }
}
