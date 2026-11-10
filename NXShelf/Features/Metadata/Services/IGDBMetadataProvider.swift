import Foundation

/// IGDB as the last media fallback for Switch ports (ADR 0038): a YouTube trailer, and screenshots and a
/// summary for anything titledb missed. Matched by exact normalised name among Switch and
/// Switch 2 games. With no credentials it reports ``MetadataLookup/unavailable``, silently.
struct IGDBMetadataProvider: MetadataProviding {
    let source = MetadataSource.igdb
    private let client: any IGDBSearching

    /// Creates the provider.
    init(client: any IGDBSearching) {
        self.client = client
    }

    func applies(to query: MetadataQuery) -> Bool {
        query.platform == .switchPort
    }

    func lookup(_ query: MetadataQuery) async throws -> MetadataLookup {
        guard let games = try await client.searchSwitchGames(title: query.title) else { return .unavailable }
        switch TitleMatch.resolve(title: query.title, among: games.map { ($0.id, $0.name) }) {
        case let .unique(id):
            return games.first { $0.id == id }.map { .found(IGDBMetadataMapper.metadata(from: $0)) } ?? .noMatch
        case .none:
            return .noMatch
        case .ambiguous:
            return .ambiguous
        }
    }
}
