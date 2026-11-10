import Foundation

/// A user's progress in one game, from `API_GetGameInfoAndUserProgress.php` (ADR 0047).
struct RetroAchievementsProgress: Decodable, Equatable, Sendable {
    /// Game ID.
    let gameID: Int
    /// RetroAchievements' title for the game.
    let title: String
    /// Achievements in the set.
    let total: Int
    /// Achievements the user has earned.
    let earned: Int
    /// The set, in display order.
    let achievements: [RetroAchievement]

    private enum CodingKeys: String, CodingKey {
        case gameID = "ID", title = "Title", total = "NumAchievements", earned = "NumAwardedToUser"
        case achievements = "Achievements"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        gameID = try container.decode(Int.self, forKey: .gameID)
        title = try container.decode(String.self, forKey: .title)
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        earned = try container.decodeIfPresent(Int.self, forKey: .earned) ?? 0
        let byID = try container.decodeIfPresent([String: RetroAchievement].self, forKey: .achievements) ?? [:]
        achievements = byID.values.sorted { ($0.displayOrder, $0.id) < ($1.displayOrder, $1.id) }
    }

    /// Creates progress.
    init(gameID: Int, title: String, total: Int, earned: Int, achievements: [RetroAchievement]) {
        self.gameID = gameID
        self.title = title
        self.total = total
        self.earned = earned
        self.achievements = achievements
    }

    /// Points earned out of the set's total.
    var points: (earned: Int, total: Int) {
        (achievements.filter(\.isEarned).reduce(0) { $0 + $1.points }, achievements.reduce(0) { $0 + $1.points })
    }
}
