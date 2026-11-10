import Foundation

/// A Twitch app access token (client-credentials grant) for IGDB.
struct IGDBToken: Decodable, Sendable {
    /// The bearer token.
    let accessToken: String
    /// Seconds until it expires.
    let expiresIn: Int
}
