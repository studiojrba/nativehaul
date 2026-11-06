import Foundation

/// SteamGridDB fallback artwork (portrait grids and heroes) through its public v2 API. Needs the user's key from the
/// Keychain; without one the provider reports ``MetadataLookup/unavailable``. Supplies art only — never text.
struct SteamGridDBMetadataProvider: MetadataProviding {
    /// Candidates offered per kind (the downloader takes the first that is a real image).
    static let candidateLimit = 3

    let source = MetadataSource.steamGridDB
    private let http: MetadataHTTP
    private let secrets: any SecretStore

    /// Creates the provider.
    init(http: any HTTPClient, secrets: any SecretStore) {
        self.http = MetadataHTTP(client: http)
        self.secrets = secrets
    }

    func lookup(_ query: MetadataQuery) async throws -> MetadataLookup {
        guard let key = try secrets.secret(for: .steamGridDBAPIKey), !key.isEmpty else { return .unavailable }
        let headers = ["Authorization": "Bearer \(key)"]
        let gameID: Int
        switch try await resolveGameID(query, headers: headers) {
        case let .unique(id): gameID = id
        case .none: return .noMatch
        case .ambiguous: return .ambiguous
        }
        var metadata = FetchedMetadata(source: .steamGridDB)
        metadata.coverCandidates = try await images(SteamGridDBEndpoint.portraitGrids(gameID: gameID), headers)
        metadata.heroCandidates = try await images(SteamGridDBEndpoint.heroes(gameID: gameID), headers)
        return .found(metadata)
    }

    private func resolveGameID(_ query: MetadataQuery, headers: [String: String]) async throws -> TitleMatch<Int> {
        if let steamAppID = query.steamAppID {
            let envelope: SteamGridDBEnvelope<SteamGridDBGame>? = try await http.get(
                SteamGridDBEndpoint.game(steamAppID: steamAppID),
                headers: headers
            )
            if let game = envelope?.data {
                return .unique(game.id)
            }
        }
        let results: SteamGridDBEnvelope<[SteamGridDBGame]>? = try await http.get(
            SteamGridDBEndpoint.search(term: query.title),
            headers: headers
        )
        return TitleMatch.resolve(title: query.title, among: (results?.data ?? []).map { ($0.id, $0.name) })
    }

    private func images(_ url: URL?, _ headers: [String: String]) async throws -> [URL] {
        let envelope: SteamGridDBEnvelope<[SteamGridDBImage]>? = try await http.get(url, headers: headers)
        let accepted = (envelope?.data ?? []).filter(\.isAcceptable).compactMap { URL(string: $0.url) }
        return Array(accepted.prefix(Self.candidateLimit))
    }
}
