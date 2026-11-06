import Foundation
import SwiftData

/// A collection or compilation (e.g. a remaster trilogy) containing ordered ``SubGame``s.
///
/// Named `GameCollection` to avoid clashing with Swift's `Collection` protocol.
@Model
final class GameCollection {
    /// Stable identifier.
    @Attribute(.unique) var id: UUID
    /// Collection name.
    var name: String
    /// Optional notes.
    var notes: String
    /// The library game this collection ships as (e.g. the compilation's store entry).
    var parentGame: Game?
    /// Contained sub-games; use ``orderedSubGames``.
    @Relationship(deleteRule: .cascade, inverse: \SubGame.collection) var subGames: [SubGame] = []

    /// Creates a collection.
    init(id: UUID = UUID(), name: String, notes: String = "", parentGame: Game? = nil) {
        self.id = id
        self.name = name
        self.notes = notes
        self.parentGame = parentGame
    }

    /// Sub-games in their stored order.
    var orderedSubGames: [SubGame] {
        subGames.sorted { $0.position < $1.position }
    }
}
