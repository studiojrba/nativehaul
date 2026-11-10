import Foundation
@testable import NXShelf

/// Recorded-shape Steam OpenID replies.
enum SteamOpenIDFixtures {
    static let steamID = "76561197960287930"
    static let configuration = SteamOpenIDConfiguration.loopback(port: MockSteamBrowserSignIn.port)
        ?? SteamOpenIDConfiguration(endpoint: URL(fileURLWithPath: "/"), realm: "", returnTo: "")
    static let returnTo = "http://127.0.0.1:51234/steam-openid/callback"

    static let validParameters: [String: String] = [
        "openid.ns": "http://specs.openid.net/auth/2.0",
        "openid.mode": "id_res",
        "openid.op_endpoint": "https://steamcommunity.com/openid/login",
        "openid.claimed_id": "https://steamcommunity.com/openid/id/\(steamID)",
        "openid.identity": "https://steamcommunity.com/openid/id/\(steamID)",
        "openid.return_to": returnTo,
        "openid.response_nonce": "2026-11-06T10:00:00ZaBcD",
        "openid.assoc_handle": "1234567890",
        "openid.signed": "signed,op_endpoint,claimed_id,identity,return_to,response_nonce,assoc_handle",
        "openid.sig": "W0u+Ab/cd=",
    ]

    static func callback(_ overrides: [String: String?] = [:]) -> URL {
        var parameters = validParameters
        for (key, value) in overrides {
            parameters[key] = value
        }
        guard var components = URLComponents(string: returnTo) else {
            return URL(fileURLWithPath: "/")
        }
        components.queryItems = parameters.sorted { $0.key < $1.key }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        let encoded = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        components.percentEncodedQuery = encoded
        return components.url ?? URL(fileURLWithPath: "/")
    }
}
