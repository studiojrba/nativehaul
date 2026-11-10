import Foundation

/// A player's achievements for one app.
struct SteamPlayerAchievements: Equatable, Sendable {
    /// Game title as reported by Steam.
    let gameName: String
    /// All achievements.
    let achievements: [SteamAchievement]

    /// Number unlocked.
    var unlockedCount: Int {
        achievements.count { $0.isUnlocked }
    }
}
