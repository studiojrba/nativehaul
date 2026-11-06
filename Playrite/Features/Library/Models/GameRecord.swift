import Foundation

/// Archive form of a ``Game``.
struct GameRecord: Codable, Equatable, Sendable {
    var id: UUID
    var title: String
    var platform: GamePlatform
    var status: GameStatus
    var summary: String
    var releaseDate: Date?
    var addedAt: Date
    var completedAt: Date?
    var lastPlayedAt: Date?
    var coverImagePath: String?
    var steamAppID: Int?
    var appBundlePath: String?
    var steamSyncedSeconds: Int?
    var selfReportedSeconds: Int?
    var steamAchievementsUnlocked: Int?
    var steamAchievementsTotal: Int?
    var sessions: [SessionRecord]
}
