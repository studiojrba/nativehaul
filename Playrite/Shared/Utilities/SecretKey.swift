import Foundation

/// Identifiers for secrets stored in the Keychain.
enum SecretKey: String, CaseIterable, Sendable {
    /// The user's Steam Web API key.
    case steamWebAPIKey = "steam.webapi.key"
    /// The user's SteamGridDB API key (optional artwork fallback).
    case steamGridDBAPIKey = "steamgriddb.api.key"
}
