import Foundation

/// Reorders items by rewriting contiguous positions. Labels such as part numbers are never touched.
enum OrderedPositions {
    /// Moves items like `Array.move(fromOffsets:toOffset:)` and returns the new order.
    static func moved<Item>(_ items: [Item], fromOffsets source: IndexSet, toOffset destination: Int) -> [Item] {
        var result = items
        result.move(fromOffsets: source, toOffset: destination)
        return result
    }

    /// Calls `assign` with each item's new zero-based position.
    static func renumber<Item>(_ items: [Item], assign: (Item, Int) -> Void) {
        for (index, item) in items.enumerated() {
            assign(item, index)
        }
    }

    /// Next free position after `positions`.
    static func nextPosition(after positions: [Int]) -> Int {
        (positions.max() ?? -1) + 1
    }
}
