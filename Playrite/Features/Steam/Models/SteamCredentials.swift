import Foundation

/// Credentials needed for a Steam Web API call. Built on demand; never persisted as a unit.
struct SteamCredentials: Sendable {
    /// Web API key, read from the Keychain.
    let apiKey: String
    /// The account whose library is read.
    let steamID: SteamID
}
