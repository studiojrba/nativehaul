import Foundation

/// Synchronises Steam data into the library. Live: ``SteamSyncService``; mock: ``MockSteamSyncService``.
@MainActor
protocol SteamSyncing: AnyObject {
    /// `true` when a key and SteamID are configured.
    var isConfigured: Bool { get }
    /// Like ``isConfigured``, but never reads the Keychain on the main thread (crash pass, ADR 0044).
    func isConfiguredOffMain() async -> Bool
    /// Checks the stored key with one lightweight call and returns the account's name and avatar.
    func loadProfile() async throws -> SteamProfileSummary?
    /// Imports owned games and SteamSynced playtime.
    func syncOwnedGames() async throws -> SteamSyncSummary
    /// Recently played games (not persisted).
    func recentlyPlayed() async throws -> [SteamRecentGame]
    /// Loads achievements for a game and stores unlocked/total counts on it.
    func loadAchievements(for game: Game) async throws -> SteamPlayerAchievements
}
