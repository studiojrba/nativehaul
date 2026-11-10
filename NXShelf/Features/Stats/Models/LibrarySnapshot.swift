import Foundation

/// Everything stats and badges need, as plain values.
struct LibrarySnapshot: Equatable, Sendable {
    /// All games.
    let games: [GameSnapshot]
    /// For each series, the statuses of its entries (nil = not in library).
    let seriesEntryStatuses: [[GameStatus?]]
    /// For each collection, the statuses of its sub-games.
    let collectionStatuses: [[GameStatus]]

    /// Empty library.
    static let empty = LibrarySnapshot(games: [], seriesEntryStatuses: [], collectionStatuses: [])
}
