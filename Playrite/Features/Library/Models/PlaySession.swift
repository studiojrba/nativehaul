import Foundation
import SwiftData

/// One continuous play session, tagged with how it was recorded.
@Model
final class PlaySession {
    /// Stable identifier.
    @Attribute(.unique) var id: UUID
    /// Session start.
    var startedAt: Date
    /// Session end.
    var endedAt: Date
    /// Raw storage for ``source``.
    var sourceRaw: String
    /// Optional note.
    var note: String
    /// Owning game.
    var game: Game?

    /// Creates a session.
    init(id: UUID = UUID(), startedAt: Date, endedAt: Date, source: PlaytimeSource, note: String = "") {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = max(startedAt, endedAt)
        sourceRaw = source.rawValue
        self.note = note
    }

    /// Typed source.
    var source: PlaytimeSource {
        get { PlaytimeSource(rawValue: sourceRaw) ?? .selfReported }
        set { sourceRaw = newValue.rawValue }
    }

    /// Whole seconds between start and end.
    var durationSeconds: Int {
        Int(endedAt.timeIntervalSince(startedAt))
    }
}
