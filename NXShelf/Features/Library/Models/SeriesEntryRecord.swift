import Foundation

/// Archive form of a ``SeriesEntry``; links by identifier.
struct SeriesEntryRecord: Codable, Equatable, Sendable {
    var id: UUID
    var partLabel: String
    var position: Int
    var gameID: UUID?
    var subGameID: UUID?
}
