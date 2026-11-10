import Foundation
import SwiftData

/// One item in a series' recommended order. Points at a ``Game`` or a ``SubGame``.
@Model
final class SeriesEntry {
    /// Stable identifier.
    @Attribute(.unique) var id: UUID
    /// The series' own part label (e.g. "1", "2", "Zero"). Never renumbered.
    var partLabel: String
    /// Position in the recommended order (ascending).
    var position: Int
    /// Linked standalone game, if any.
    var game: Game?
    /// Linked sub-game inside a collection, if any.
    var subGame: SubGame?
    /// Owning series.
    var series: Series?

    /// Creates an entry.
    init(id: UUID = UUID(), partLabel: String, position: Int, game: Game? = nil, subGame: SubGame? = nil) {
        self.id = id
        self.partLabel = partLabel
        self.position = position
        self.game = game
        self.subGame = subGame
    }
}
