import Foundation

/// Synchronises Steam data into the library. Live: ``SteamSyncService``; mock: ``MockSteamSyncService``.
@MainActor
protocol SteamSyncing: AnyObject {
    /// `true` when a key and SteamID are configured.
    var isConfigured: Bool { get }
    /// Imports owned games and SteamSynced playtime.
    func syncOwnedGames() async throws -> SteamSyncSummary
    /// Recently played games (not persisted).
    func recentlyPlayed() async throws -> [SteamRecentGame]
    /// Loads achievements for a game and stores unlocked/total counts on it.
    func loadAchievements(for game: Game) async throws -> SteamPlayerAchievements
}
