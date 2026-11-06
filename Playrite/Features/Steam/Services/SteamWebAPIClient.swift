import Foundation

/// Live ``SteamClientProtocol`` over an ``HTTPClient``.
struct SteamWebAPIClient: SteamClientProtocol {
    private enum Status {
        static let okLowerBound = 200
        static let okUpperBound = 300
        static let badRequest = 400
        static let unauthorizedCode = 401
        static let forbiddenCode = 403
        static let success = okLowerBound ..< okUpperBound
        static let unauthorized: Set<Int> = [unauthorizedCode, forbiddenCode]
    }

    private let http: any HTTPClient

    /// Creates a client.
    init(http: any HTTPClient) {
        self.http = http
    }

    func ownedGames(credentials: SteamCredentials) async throws -> [SteamOwnedGame] {
        let envelope: SteamOwnedGamesEnvelope = try await get(SteamEndpoint.ownedGames(credentials))
        guard let games = envelope.response.games else { throw SteamError.profileNotPublic }
        return games
    }

    func recentlyPlayedGames(credentials: SteamCredentials) async throws -> [SteamRecentGame] {
        let envelope: SteamRecentGamesEnvelope = try await get(SteamEndpoint.recentlyPlayedGames(credentials))
        return envelope.response.games ?? []
    }

    func playerSummary(credentials: SteamCredentials) async throws -> SteamProfileSummary? {
        let envelope: SteamPlayerSummariesEnvelope = try await get(SteamEndpoint.playerSummaries(credentials))
        return envelope.response.players.first?.summary
    }

    func playerAchievements(appID: Int, credentials: SteamCredentials) async throws -> SteamPlayerAchievements {
        let url = SteamEndpoint.playerAchievements(appID: appID, credentials: credentials)
        let envelope: SteamPlayerStatsEnvelope = try await get(url, acceptingBadRequestBody: true)
        let stats = envelope.playerstats
        guard stats.success, let achievements = stats.achievements else {
            throw SteamError.noStats(stats.error ?? "Unknown reason")
        }
        return SteamPlayerAchievements(gameName: stats.gameName ?? "", achievements: achievements)
    }

    private func get<Response: Decodable>(_ url: URL?, acceptingBadRequestBody: Bool = false) async throws -> Response {
        guard let url else { throw SteamError.decoding }
        let (data, response) = try await http.data(for: URLRequest(url: url))
        let status = response.statusCode
        if Status.unauthorized.contains(status) {
            throw SteamError.invalidAPIKey
        }
        let isAcceptable = Status.success.contains(status) || (acceptingBadRequestBody && status == Status.badRequest)
        guard isAcceptable else { throw SteamError.http(status: status) }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw status == Status.badRequest ? SteamError.http(status: status) : SteamError.decoding
        }
    }
}
