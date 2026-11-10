import Foundation

/// One achievement from `ISteamUserStats/GetPlayerAchievements`.
struct SteamAchievement: Decodable, Equatable, Sendable, Identifiable {
    /// API identifier.
    let apiname: String
    /// `1` when unlocked.
    let achieved: Int
    /// Unix unlock time, `0` when locked.
    let unlocktime: Int?
    /// Localised display name (when `l=` is supplied).
    let name: String?
    /// Localised description.
    let description: String?

    /// Identity for lists.
    var id: String {
        apiname
    }

    /// `true` when unlocked.
    var isUnlocked: Bool {
        achieved != 0
    }
}
