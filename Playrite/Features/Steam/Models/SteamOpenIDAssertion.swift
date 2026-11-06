import Foundation

/// A Steam OpenID response that passed the local checks and still needs Steam's own confirmation
/// (`check_authentication`) before the SteamID can be trusted.
struct SteamOpenIDAssertion: Equatable, Sendable {
    /// Every `openid.*` parameter Steam sent, unchanged.
    let parameters: [String: String]
    /// The SteamID64 in the claimed identity.
    let steamID: SteamID
}
