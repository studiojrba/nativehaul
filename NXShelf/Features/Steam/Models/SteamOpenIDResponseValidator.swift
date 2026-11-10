import Foundation

/// Local checks on Steam's OpenID reply. It passes only a reply that came from Steam, to our return address, and
/// carries a signed Steam identity. Steam's own `check_authentication` call must still confirm it.
enum SteamOpenIDResponseValidator {
    private static let parameterPrefix = "openid."

    /// Validates the callback URL and extracts the claimed SteamID.
    static func validate(_ callback: URL, configuration: SteamOpenIDConfiguration) throws -> SteamOpenIDAssertion {
        let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
        var parameters: [String: String] = [:]
        for item in items where item.name.hasPrefix(parameterPrefix) {
            parameters[item.name] = item.value ?? ""
        }
        func value(_ key: String) -> String? {
            parameters[parameterPrefix + key]
        }
        if value("mode") == "cancel" {
            throw SteamSignInError.cancelled
        }
        guard value("mode") == "id_res", value("ns") == SteamOpenID.namespace else {
            throw SteamSignInError.notASteamResponse
        }
        guard value("op_endpoint") == SteamOpenID.providerEndpoint,
              value("return_to") == configuration.returnTo
        else { throw SteamSignInError.untrustedResponse }
        let signed = Set((value("signed") ?? "").split(separator: ",").map(String.init))
        guard value("sig")?.isEmpty == false, SteamOpenID.requiredSignedFields.isSubset(of: signed) else {
            throw SteamSignInError.untrustedResponse
        }
        guard let claimed = value("claimed_id"), claimed == value("identity"),
              claimed.hasPrefix(SteamOpenID.claimedIDPrefix),
              let steamID = SteamID(String(claimed.dropFirst(SteamOpenID.claimedIDPrefix.count)))
        else { throw SteamSignInError.invalidIdentity }
        return SteamOpenIDAssertion(parameters: parameters, steamID: steamID)
    }
}
