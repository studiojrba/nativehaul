import Foundation
import SwiftData

/// A game contained in a ``GameCollection``, with its own status.
@Model
final class SubGame {
    /// Stable identifier.
    @Attribute(.unique) var id: UUID
    /// Title of the contained game.
    var title: String
    /// Position within the collection (ascending).
    var position: Int
    /// Raw storage for ``status``.
    var statusRaw: String
    /// Owning collection.
    var collection: GameCollection?

    /// Creates a sub-game.
    init(id: UUID = UUID(), title: String, position: Int, status: GameStatus = .backlog) {
        self.id = id
        self.title = title
        self.position = position
        statusRaw = status.rawValue
    }

    /// Typed status.
    var status: GameStatus {
        get { GameStatus(rawValue: statusRaw) ?? .backlog }
        set { statusRaw = newValue.rawValue }
    }
}
