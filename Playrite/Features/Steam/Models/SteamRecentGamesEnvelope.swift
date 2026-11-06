import Foundation

/// Wire envelope for `GetRecentlyPlayedGames`.
struct SteamRecentGamesEnvelope: Decodable, Sendable {
    /// Inner payload.
    struct Payload: Decodable, Sendable {
        /// Recently played games, if any.
        let games: [SteamRecentGame]?
    }

    /// Payload.
    let response: Payload
}
