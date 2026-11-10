import Foundation

/// The Twitch developer credentials IGDB requires (ADR 0038). Kept only in the Keychain.
struct IGDBCredentials: Equatable, Sendable {
    /// Twitch Client ID.
    let clientID: String
    /// Twitch client secret.
    let clientSecret: String
}
