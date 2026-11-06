import Foundation

/// Steam OpenID 2.0 settings for "Sign in through Steam".
///
/// Steam only accepts http(s) return addresses, so the reply comes back to a one-shot listener on this Mac's
/// loopback address (`http://127.0.0.1:<port>/…`, RFC 8252). Nothing leaves the device except the user's own visit to
/// steamcommunity.com and the `check_authentication` call.
struct SteamOpenIDConfiguration: Equatable, Sendable {
    /// Path the loopback listener answers.
    static let callbackPath = "/steam-openid/callback"
    /// Loopback host. An IP literal, not "localhost", so the address can't resolve anywhere else.
    static let loopbackHost = "127.0.0.1"

    /// Steam's OpenID provider endpoint.
    let endpoint: URL
    /// The realm Steam shows on its sign-in page.
    let realm: String
    /// Where Steam sends the signed response.
    let returnTo: String

    /// Settings for a listener on `port`.
    static func loopback(port: UInt16, endpoint: URL? = URL(string: SteamOpenID.providerEndpoint)) -> Self? {
        guard let endpoint else { return nil }
        let origin = "http://\(loopbackHost):\(port)"
        return SteamOpenIDConfiguration(endpoint: endpoint, realm: origin + "/", returnTo: origin + callbackPath)
    }
}
