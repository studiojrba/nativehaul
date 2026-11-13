import Foundation

/// Couch Home's focus (spec §3.7): rows −2 (the hero's arrow pair), −1 (the hero) and 0…n (shelves); each shelf keeps
/// its own focus column — a tile index, −1 for its left arrow or its count for its right arrow — and its first visible
/// tile.
struct CouchHomeFocus: Equatable, Sendable {
    /// The hero's arrow pair.
    static let heroArrowsRow = -2
    /// The hero.
    static let heroRow = -1
    /// A shelf's left arrow, as a focus column.
    static let leftArrowColumn = -1

    /// The focused row.
    var row = heroRow
    /// Each shelf's focus column.
    var columns: [Int] = []
    /// Each shelf's first visible tile.
    var starts: [Int] = []
    /// Which hero arrow is focused on the arrow row (`.left` or `.right`).
    var heroArrow = CouchDirection.right

    /// Keeps one column and start per shelf (new shelves start at their first tile).
    mutating func fit(shelfCount: Int) {
        columns = Array(columns.prefix(shelfCount)) + Array(repeating: 0, count: max(0, shelfCount - columns.count))
        starts = Array(starts.prefix(shelfCount)) + Array(repeating: 0, count: max(0, shelfCount - starts.count))
    }
}
