import Foundation

/// Identifiers for secrets stored in the Keychain.
enum SecretKey: String, CaseIterable, Sendable {
    /// The user's SteamGridDB API key (optional artwork fallback).
    case steamGridDBAPIKey = "steamgriddb.api.key"
    /// Twitch developer Client ID for IGDB (optional media fallback, ADR 0038).
    case twitchClientID = "twitch.client.id"
    /// Twitch developer client secret for IGDB.
    case twitchClientSecret = "twitch.client.secret"
    /// RetroAchievements username (ADR 0047).
    case retroAchievementsUsername = "retroachievements.username"
    /// RetroAchievements web API key.
    case retroAchievementsAPIKey = "retroachievements.apikey"
}
