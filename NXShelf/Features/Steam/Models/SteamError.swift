import Foundation

/// Errors from the Steam provider. Messages never include the API key.
enum SteamError: Error, Equatable, LocalizedError {
    /// No API key is stored in the Keychain.
    case missingAPIKey
    /// No (valid) SteamID64 is configured.
    case missingSteamID
    /// Steam rejected the key (HTTP 401/403).
    case invalidAPIKey
    /// The profile's game details are private, so Steam returned no data.
    case profileNotPublic
    /// The game exposes no achievement stats.
    case noStats(String)
    /// Unexpected HTTP status.
    case http(status: Int)
    /// The response could not be decoded.
    case decoding

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case .missingAPIKey: "No Steam Web API key configured. Add one in Settings → Steam."
        case .missingSteamID: "No valid SteamID64 configured. Add it in Settings → Steam."
        case .invalidAPIKey: "Steam rejected the API key. Check it in Settings → Steam."
        case .profileNotPublic:
            "Steam returned no games because your profile's game details are private. In Steam's privacy settings, "
                + "set Game details to Public."
        case let .noStats(message): "No achievements available: \(message)"
        case let .http(status): "Steam returned HTTP \(status)."
        case .decoding: "Steam's response could not be read."
        }
    }
}
