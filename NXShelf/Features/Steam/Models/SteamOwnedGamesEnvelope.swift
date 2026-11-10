import Foundation

/// Wire envelope for `GetOwnedGames`. `games` is absent when the profile is private.
struct SteamOwnedGamesEnvelope: Decodable, Sendable {
    /// Inner payload.
    struct Payload: Decodable, Sendable {
        /// Owned games, if visible.
        let games: [SteamOwnedGame]?
    }

    /// Payload.
    let response: Payload
}
