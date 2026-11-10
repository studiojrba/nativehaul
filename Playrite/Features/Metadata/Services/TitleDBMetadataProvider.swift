import Foundation

/// Nintendo eShop media for Switch ports from titledb (ADR 0038): the port's title ID is joined to a region record,
/// which supplies the official description, screenshots and key art. With no dataset the provider reports
/// ``MetadataLookup/unavailable`` and the pass carries on without it.
struct TitleDBMetadataProvider: MetadataProviding {
    let source = MetadataSource.titleDB
    private let store: any TitleDBStoring

    /// Creates the provider over a dataset store.
    init(store: any TitleDBStoring) {
        self.store = store
    }

    func applies(to query: MetadataQuery) -> Bool {
        query.platform == .switchPort
    }

    func lookup(_ query: MetadataQuery) async throws -> MetadataLookup {
        guard let index = await store.index() else { return .unavailable }
        guard let entry = index.resolve(titleID: query.switchTitleID, title: query.title) else { return .noMatch }
        return .found(TitleDBMetadataMapper.metadata(from: entry))
    }
}
