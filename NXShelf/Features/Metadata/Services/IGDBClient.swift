import Foundation

/// Live ``IGDBSearching`` (ADR 0038). Reads the Twitch credentials from the Keychain on each search, so adding them
/// in Settings turns the feature on without a relaunch. It gets an app access token (client-credentials grant),
/// keeps it until shortly before it expires, and retries once with a fresh token when IGDB rejects one.
actor IGDBClient: IGDBSearching {
    private static let okRange = 200 ..< 300
    private static let unauthorizedCode = 401
    private static let forbiddenCode = 403
    private static let unauthorized: Set<Int> = [unauthorizedCode, forbiddenCode]
    private static let badRequest = 400
    /// A search is tried with the cached token, then once more with a fresh one.
    private static let attempts = 2
    /// Renew this long before the token's stated expiry.
    private static let expiryMargin: TimeInterval = 300

    private let http: any HTTPClient
    private let credentials: any IGDBCredentialStoring
    private let now: @Sendable () -> Date
    private var token: CachedToken?

    /// A token and when to stop using it.
    private struct CachedToken {
        let value: String
        let expires: Date
        let clientID: String
    }

    /// Creates the client.
    init(
        http: any HTTPClient,
        credentials: any IGDBCredentialStoring,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.http = http
        self.credentials = credentials
        self.now = now
    }

    func searchSwitchGames(title: String) async throws -> [IGDBGame]? {
        guard let credentials = credentials.credentials() else { return nil }
        for attempt in 0 ..< Self.attempts {
            guard let bearer = try await bearer(for: credentials, renew: attempt > 0) else { return nil }
            guard let url = IGDBEndpoint.games else { throw MetadataError.badURL }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(credentials.clientID, forHTTPHeaderField: "Client-ID")
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = IGDBEndpoint.searchBody(title: title)
            let (data, response) = try await http.data(for: request)
            if Self.unauthorized.contains(response.statusCode) {
                token = nil
                continue
            }
            guard Self.okRange.contains(response.statusCode) else {
                throw MetadataError.http(status: response.statusCode)
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                return try decoder.decode([IGDBGame].self, from: data)
            } catch {
                throw MetadataError.decoding
            }
        }
        return nil
    }

    /// A valid bearer token, or `nil` when Twitch refuses the credentials.
    private func bearer(for credentials: IGDBCredentials, renew: Bool) async throws -> String? {
        if !renew, let token, token.clientID == credentials.clientID, token.expires > now() {
            return token.value
        }
        guard let url = IGDBEndpoint.token else { throw MetadataError.badURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = IGDBEndpoint.tokenBody(credentials)
        let (data, response) = try await http.data(for: request)
        if response.statusCode == Self.badRequest || Self.unauthorized.contains(response.statusCode) {
            token = nil
            return nil
        }
        guard Self.okRange.contains(response.statusCode) else { throw MetadataError.http(status: response.statusCode) }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let fresh = try? decoder.decode(IGDBToken.self, from: data) else { throw MetadataError.decoding }
        let expires = now().addingTimeInterval(TimeInterval(fresh.expiresIn) - Self.expiryMargin)
        token = CachedToken(value: fresh.accessToken, expires: expires, clientID: credentials.clientID)
        return fresh.accessToken
    }
}
