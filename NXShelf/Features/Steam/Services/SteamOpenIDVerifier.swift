import Foundation

/// Asks Steam to confirm an OpenID reply (`openid.mode=check_authentication`). Only a reply Steam answers with
/// `is_valid:true` is trusted.
struct SteamOpenIDVerifier: Sendable {
    private static let okLowerBound = 200
    private static let okUpperBound = 300
    private static let validLine = "is_valid:true"
    private static let formAllowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))

    private let http: any HTTPClient

    /// Creates the verifier.
    init(http: any HTTPClient) {
        self.http = http
    }

    /// Throws unless Steam confirms the assertion.
    func confirm(_ assertion: SteamOpenIDAssertion, configuration: SteamOpenIDConfiguration) async throws {
        var parameters = assertion.parameters
        parameters["openid.mode"] = "check_authentication"
        var request = URLRequest(url: configuration.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(Self.formEncode(parameters).utf8)
        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await http.data(for: request)
        } catch {
            throw SteamSignInError.couldNotConfirm
        }
        guard (Self.okLowerBound ..< Self.okUpperBound).contains(response.statusCode) else {
            throw SteamSignInError.couldNotConfirm
        }
        let lines = (String(bytes: data, encoding: .utf8) ?? "").split(whereSeparator: \.isNewline)
        guard lines.contains(where: { $0.trimmingCharacters(in: .whitespaces) == Self.validLine }) else {
            throw SteamSignInError.rejectedBySteam
        }
    }

    /// `application/x-www-form-urlencoded` body, keys sorted for stable output.
    static func formEncode(_ parameters: [String: String]) -> String {
        parameters.sorted { $0.key < $1.key }.map { key, value in
            "\(encode(key))=\(encode(value))"
        }.joined(separator: "&")
    }

    private static func encode(_ text: String) -> String {
        text.addingPercentEncoding(withAllowedCharacters: formAllowed) ?? text
    }
}
