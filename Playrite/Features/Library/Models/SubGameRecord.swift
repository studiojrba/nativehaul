import Foundation

/// Archive form of a ``SubGame``.
struct SubGameRecord: Codable, Equatable, Sendable {
    var id: UUID
    var title: String
    var position: Int
    var status: GameStatus
}
