import Foundation

/// Read-only access to the Steam Web API. Live: ``SteamWebAPIClient``; mock: ``MockSteamClient``.
protocol SteamClientProtocol: Sendable {
    /// `GetOwnedGames` — every game on the account, with lifetime playtime.
    func ownedGames(credentials: SteamCredentials) async throws -> [SteamOwnedGame]
    /// `GetRecentlyPlayedGames` — games played in the last two weeks.
    func recentlyPlayedGames(credentials: SteamCredentials) async throws -> [SteamRecentGame]
    /// `GetPlayerSummaries` for the configured account — a lightweight call used to check the key.
    func playerSummary(credentials: SteamCredentials) async throws -> SteamProfileSummary?
    /// `GetPlayerAchievements` — the player's achievements for one app.
    func playerAchievements(appID: Int, credentials: SteamCredentials) async throws -> SteamPlayerAchievements
}
