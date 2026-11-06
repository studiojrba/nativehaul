import Foundation

/// Wire envelope for `GetPlayerAchievements`.
struct SteamPlayerStatsEnvelope: Decodable, Sendable {
    /// Inner payload.
    struct Payload: Decodable, Sendable {
        /// Game title.
        let gameName: String?
        /// Achievements, absent for games without stats.
        let achievements: [SteamAchievement]?
        /// Whether the call succeeded.
        let success: Bool
        /// Error message on failure.
        let error: String?
    }

    /// Payload.
    let playerstats: Payload
}
