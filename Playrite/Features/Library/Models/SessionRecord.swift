import Foundation

/// Archive form of a ``PlaySession``.
struct SessionRecord: Codable, Equatable, Sendable {
    var id: UUID
    var startedAt: Date
    var endedAt: Date
    var source: PlaytimeSource
    var note: String
}
