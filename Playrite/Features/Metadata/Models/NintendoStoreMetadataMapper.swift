import Foundation

/// Pure mapping from a Nintendo eShop listing to ``FetchedMetadata``. Only official key art is used (as the hero);
/// no cover is taken, because Nintendo's portrait images are packshots.
enum NintendoStoreMetadataMapper {
    /// Metadata from `hit`.
    static func metadata(from hit: NintendoStoreHit) -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .nintendoStore)
        metadata.description = hit.description.map(HTMLText.plain).flatMap { $0.isEmpty ? nil : $0 }
        metadata.developer = hit.developer.flatMap { $0.isEmpty ? nil : $0 }
        metadata.genres = hit.genres ?? []
        metadata.releaseDate = StoreReleaseDateParser.date(from: hit.releaseDate)
        metadata.heroCandidates = [hit.keyArtURL].compactMap { $0.flatMap(URL.init(string:)) }
        return metadata
    }
}
