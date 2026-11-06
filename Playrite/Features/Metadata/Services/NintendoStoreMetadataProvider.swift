import Foundation

/// Official Nintendo eShop listing data for Switch games that have no Steam twin. Accepts only a single exact
/// normalised-title match among Switch listings.
struct NintendoStoreMetadataProvider: MetadataProviding {
    let source = MetadataSource.nintendoStore
    private let store: any NintendoStoreSearching

    /// Creates the provider over a listing source.
    init(store: any NintendoStoreSearching) {
        self.store = store
    }

    func applies(to query: MetadataQuery) -> Bool {
        query.platform == .switchPort
    }

    func lookup(_ query: MetadataQuery) async throws -> MetadataLookup {
        guard store.isAvailable else { return .unavailable }
        let hits = try await store.search(title: query.title).filter(\.isSwitch)
        switch TitleMatch.resolve(title: query.title, among: hits.map { ($0.listingID, $0.title) }) {
        case let .unique(listingID):
            guard let hit = hits.first(where: { $0.listingID == listingID }) else { return .noMatch }
            return .found(NintendoStoreMetadataMapper.metadata(from: hit))
        case .none:
            return .noMatch
        case .ambiguous:
            return .ambiguous
        }
    }
}
