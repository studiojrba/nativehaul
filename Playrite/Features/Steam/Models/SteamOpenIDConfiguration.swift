import Foundation

/// Steam OpenID 2.0 settings for "Sign in through Steam".
///
/// Steam redirects to `returnTo`, which uses the app's own URL scheme so `ASWebAuthenticationSession` can catch it.
struct SteamOpenIDConfiguration: Equatable, Sendable {
    /// Steam's OpenID provider endpoint.
    let endpoint: URL
    /// The realm Steam shows on its sign-in page.
    let realm: String
    /// Where Steam sends the signed response.
    let returnTo: String
    /// URL scheme the web session listens for.
    let callbackScheme: String

    /// Live configuration.
    static let standard: SteamOpenIDConfiguration = {
        guard let endpoint = URL(string: SteamOpenID.providerEndpoint) else {
            preconditionFailure("Steam OpenID endpoint is a constant and must parse")
        }
        return SteamOpenIDConfiguration(
            endpoint: endpoint,
            realm: "retriever://steam-openid/",
            returnTo: "retriever://steam-openid/callback",
            callbackScheme: "retriever"
        )
    }()
}
