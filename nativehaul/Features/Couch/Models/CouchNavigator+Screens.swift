import Foundation

/// The mirrored screens under the couch model (ADR 0058): Library's grid moves in reading order, Detail's buttons left
/// to right, Builds and Settings top to bottom. Left from a screen's first column reaches the nav column; B goes back.
extension CouchNavigator {
    static func reduceLibrary(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        context: CouchContext
    ) -> [CouchEffect] {
        let items = context.library
        let columns = max(1, context.libraryColumns)
        guard !items.isEmpty else {
            return input == .move(.left) ? focusNav(&state) : (input == .back ? back(&state) : [])
        }
        let index = min(state.libraryIndex, items.count - 1)
        switch input {
        case .move(.left) where index % columns == 0:
            return focusNav(&state)
        case let .move(direction):
            let target = gridTarget(from: index, direction, columns: columns, count: items.count)
            guard target != index else { return [] }
            state.libraryIndex = target
            return [.sound(.navigate)]
        case .select:
            return [.play(items[index].id)]
        case .details:
            return [.sound(.confirm), .openDetails(items[index].id)]
        case .previousLetter, .nextLetter:
            let titles = items.map(\.title)
            let target = input == .nextLetter
                ? LetterJump.next(from: index, titles: titles)
                : LetterJump.previous(from: index, titles: titles)
            state.libraryIndex = target
            return [.sound(.navigate), .toast(.letter(LetterJump.initial(of: titles[target])))]
        case .back:
            return back(&state)
        default:
            return []
        }
    }

    /// Reading-order grid moves: Left/Right step through the order (Right wraps onto the next row), Up/Down move a row,
    /// and Down from a row above a shorter last row lands on the last tile.
    static func gridTarget(from index: Int, _ direction: CouchDirection, columns: Int, count: Int) -> Int {
        switch direction {
        case .left:
            return max(0, index - 1)
        case .right:
            return min(count - 1, index + 1)
        case .up:
            return index - columns >= 0 ? index - columns : index
        case .down:
            if index + columns < count {
                return index + columns
            }
            return index / columns < (count - 1) / columns ? count - 1 : index
        }
    }

    static func reduceDetail(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        context: CouchContext
    ) -> [CouchEffect] {
        let actions = context.detailActions
        let index = min(state.detailIndex, max(0, actions.count - 1))
        switch input {
        case .move(.left):
            guard index > 0 else { return focusNav(&state) }
            state.detailIndex = index - 1
            return [.sound(.navigate)]
        case .move(.right):
            guard index < actions.count - 1 else { return [] }
            state.detailIndex = index + 1
            return [.sound(.navigate)]
        case .select:
            guard actions.indices.contains(index), let gameID = state.detailGameID else { return [] }
            switch actions[index] {
            case .play: return [.play(gameID)]
            case .favorite: return [.sound(.confirm), .toggleFavorite]
            }
        case .back:
            return back(&state)
        default:
            return []
        }
    }

    static func reduceBuilds(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        context: CouchContext
    ) -> [CouchEffect] {
        let count = context.buildCount
        let index = min(state.buildsIndex, max(0, count - 1))
        switch input {
        case .move(.left):
            return focusNav(&state)
        case .move(.up) where index > 0, .move(.down) where index < count - 1:
            state.buildsIndex = input == .move(.up) ? index - 1 : index + 1
            return [.sound(.navigate), .selectBuild(state.buildsIndex)]
        case .select where count > 0:
            return [.sound(.confirm), .openBuild(index)]
        case .back:
            return back(&state)
        default:
            return []
        }
    }

    static func reduceSettings(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        context: CouchContext
    ) -> [CouchEffect] {
        let rows = context.settingsRows
        guard !rows.isEmpty else { return input == .back ? back(&state) : [] }
        let index = min(state.settingsIndex, rows.count - 1)
        let row = rows[index]
        switch input {
        case .move(.up) where index > 0, .move(.down) where index < rows.count - 1:
            state.settingsIndex = input == .move(.up) ? index - 1 : index + 1
            return [.sound(.navigate)]
        case .move(.left):
            return row.isAdjustable ? [.sound(.navigate), .setting(row, .decrease)] : focusNav(&state)
        case .move(.right) where row.isAdjustable:
            return [.sound(.navigate), .setting(row, .increase)]
        case .select where row == .exitToDesktop:
            return [.sound(.back), .exitToDesktop]
        case .select:
            return [.sound(.confirm), .setting(row, .activate)]
        case .back:
            return back(&state)
        default:
            return []
        }
    }
}
