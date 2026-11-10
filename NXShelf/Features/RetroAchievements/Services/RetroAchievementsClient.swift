import Foundation

/// The RetroAchievements web API (ADR 0047), `https://retroachievements.org/API/`. The web API key travels as the
/// documented `y` parameter, to RetroAchievements only, and is never logged. Each console's game list (with hashes)
/// is large, so it is fetched once per session and cached. With no credentials nothing is requested.
actor RetroAchievementsClient {
    private static let base = "https://retroachievements.org/API/"
    private static let okRange = 200 ..< 300

    private let http: any HTTPClient
    private let credentials: any RetroAchievementsCredentialStoring
    private var gameLists: [Int: [RetroAchievementsGameListEntry]] = [:]

    /// Creates the client.
    init(http: any HTTPClient, credentials: any RetroAchievementsCredentialStoring) {
        self.http = http
        self.credentials = credentials
    }

    /// Whether credentials are stored (read off the main thread, inside the actor).
    var isConfigured: Bool {
        credentials.credentials() != nil
    }

    /// The game whose supported hashes include `hash` on `consoleID`, or `nil`.
    func gameID(matching hash: String, consoleID: Int) async throws -> Int? {
        guard let credentials = credentials.credentials() else { return nil }
        let list: [RetroAchievementsGameListEntry]
        if let cached = gameLists[consoleID] {
            list = cached
        } else {
            list = try await get(
                "API_GetGameList.php",
                ["i": String(consoleID), "h": "1", "f": "1"],
                key: credentials.apiKey
            )
            gameLists[consoleID] = list
        }
        let wanted = hash.lowercased()
        return list.first { $0.hashes.contains { $0.lowercased() == wanted } }?.id
    }

    /// The user's progress in `gameID`, or `nil` without credentials.
    func progress(gameID: Int) async throws -> RetroAchievementsProgress? {
        guard let credentials = credentials.credentials() else { return nil }
        return try await get(
            "API_GetGameInfoAndUserProgress.php",
            ["g": String(gameID), "u": credentials.username],
            key: credentials.apiKey
        )
    }

    private func get<Response: Decodable>(
        _ endpoint: String,
        _ parameters: [String: String],
        key: String
    ) async throws -> Response {
        var components = URLComponents(string: Self.base + endpoint)
        components?.queryItems = parameters.sorted { $0.key < $1.key }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
            + [URLQueryItem(name: "y", value: key)]
        guard let url = components?.url else { throw MetadataError.badURL }
        let (data, response) = try await http.data(for: URLRequest(url: url))
        guard Self.okRange.contains(response.statusCode) else { throw MetadataError.http(status: response.statusCode) }
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw MetadataError.decoding
        }
    }
}
