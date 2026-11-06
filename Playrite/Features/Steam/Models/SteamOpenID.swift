import Foundation

/// Fixed values of the OpenID 2.0 protocol as Steam uses it.
enum SteamOpenID {
    /// OpenID 2.0 namespace.
    static let namespace = "http://specs.openid.net/auth/2.0"
    /// "Let the provider pick the identity".
    static let identifierSelect = "http://specs.openid.net/auth/2.0/identifier_select"
    /// Steam's provider endpoint (also the only acceptable `openid.op_endpoint`).
    static let providerEndpoint = "https://steamcommunity.com/openid/login"
    /// Prefix of a Steam claimed identity; the SteamID64 follows it.
    static let claimedIDPrefix = "https://steamcommunity.com/openid/id/"
    /// Fields that must be covered by Steam's signature.
    static let requiredSignedFields: Set<String> = [
        "op_endpoint", "claimed_id", "identity", "return_to", "response_nonce", "assoc_handle",
    ]

    /// The browser URL that starts sign-in.
    static func loginURL(_ configuration: SteamOpenIDConfiguration) -> URL? {
        var components = URLComponents(url: configuration.endpoint, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "openid.ns", value: namespace),
            URLQueryItem(name: "openid.mode", value: "checkid_setup"),
            URLQueryItem(name: "openid.return_to", value: configuration.returnTo),
            URLQueryItem(name: "openid.realm", value: configuration.realm),
            URLQueryItem(name: "openid.identity", value: identifierSelect),
            URLQueryItem(name: "openid.claimed_id", value: identifierSelect),
        ]
        return components?.url
    }
}
