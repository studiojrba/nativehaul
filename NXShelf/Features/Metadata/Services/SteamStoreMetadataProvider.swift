import Foundation

/// Official Steam store metadata and artwork from the public `appdetails` endpoint (no Web API key).
///
/// Uses the game's Steam app ID when it has one; otherwise searches the store and accepts only a single exact
/// normalised-title match.
struct SteamStoreMetadataProvider: MetadataProviding {
    let source = MetadataSource.steamStore
    private let http: MetadataHTTP

    /// Creates the provider. Pass a throttled client in the live app.
    init(http: any HTTPClient) {
        self.http = MetadataHTTP(client: http)
    }

    /// Emulated games are left to SteamGridDB, which covers retro systems; a Steam title search could match a modern
    /// re-release instead.
    func applies(to query: MetadataQuery) -> Bool {
        query.platform != .emulated
    }

    func lookup(_ query: MetadataQuery) async throws -> MetadataLookup {
        let appID: Int
        if let steamAppID = query.steamAppID {
            appID = steamAppID
        } else {
            switch try await searchAppID(title: query.title) {
            case let .unique(id): appID = id
            case .none: return .noMatch
            case .ambiguous: return .ambiguous
            }
        }
        let envelopes: [String: SteamStoreAppDetailsEnvelope]? = try await http.get(
            SteamStoreEndpoint.appDetails(appID: appID)
        )
        guard let envelope = envelopes?[String(appID)], envelope.success, let details = envelope.data else {
            return .noMatch
        }
        return .found(SteamStoreMetadataMapper.metadata(from: details, appID: appID))
    }

    private func searchAppID(title: String) async throws -> TitleMatch<Int> {
        let response: SteamStoreSearchResponse? = try await http.get(SteamStoreEndpoint.search(term: title))
        let apps = (response?.items ?? []).filter { $0.type == nil || $0.type == "app" }
        return TitleMatch.resolve(title: title, among: apps.map { ($0.id, $0.name) })
    }
}
