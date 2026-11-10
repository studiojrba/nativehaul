import Foundation

/// Pure mapping from a titledb entry to ``FetchedMetadata`` (ADR 0038): the official description, the screenshots
/// for the slideshow, and the key art as a hero candidate. Covers are not taken: titledb's portrait art is box art
/// with rating badges, which the official-art rule excludes.
enum TitleDBMetadataMapper {
    /// Width of titledb's key art (Nintendo's eShop banners are 1920×1080), used to judge a hero upgrade.
    static let bannerPixelWidth = 1920

    /// Metadata for `entry`.
    static func metadata(from entry: TitleDBEntry) -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .titleDB)
        let description = entry.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        metadata.description = description?.isEmpty == false ? description : nil
        metadata.carouselImages = entry.screenshots.compactMap(URL.init(string:))
        metadata.heroCandidates = [entry.bannerURL].compactMap { $0.flatMap(URL.init(string:)) }
        return metadata
    }
}
