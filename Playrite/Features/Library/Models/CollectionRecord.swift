import Foundation

/// Archive form of a ``GameCollection``.
struct CollectionRecord: Codable, Equatable, Sendable {
    var id: UUID
    var name: String
    var notes: String
    var parentGameID: UUID?
    var subGames: [SubGameRecord]
}
