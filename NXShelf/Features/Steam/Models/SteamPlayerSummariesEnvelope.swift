import Foundation

/// `ISteamUser/GetPlayerSummaries/v2` response.
struct SteamPlayerSummariesEnvelope: Decodable, Sendable {
    /// Wrapper.
    struct Response: Decodable, Sendable {
        /// Matching players.
        let players: [SteamPlayer]
    }

    /// Wrapper.
    let response: Response
}
