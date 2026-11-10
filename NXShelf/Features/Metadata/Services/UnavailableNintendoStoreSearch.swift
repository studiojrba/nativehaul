import Foundation

/// Live placeholder: no approved Nintendo metadata source is connected, so Nintendo lookups report
/// ``MetadataLookup/unavailable`` and SteamGridDB fills the art instead.
struct UnavailableNintendoStoreSearch: NintendoStoreSearching {
    let isAvailable = false

    /// Creates the placeholder.
    init() {}

    func search(title _: String) async throws -> [NintendoStoreHit] {
        []
    }
}
