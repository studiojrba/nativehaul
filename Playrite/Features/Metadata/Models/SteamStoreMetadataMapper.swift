import Foundation

/// Pure mapping from a Steam store `appdetails` payload to ``FetchedMetadata``.
enum SteamStoreMetadataMapper {
    /// Most screenshots kept for the carousel.
    static let screenshotLimit = 8
    /// Most trailer thumbnails kept for the carousel.
    static let movieThumbnailLimit = 2

    /// Metadata for `appID` from its store details.
    static func metadata(from details: SteamStoreAppDetails, appID: Int) -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .steamStore)
        let description = details.shortDescription.map(HTMLText.plain).flatMap { $0.isEmpty ? nil : $0 }
        metadata.description = description ?? details.aboutTheGame.map(HTMLText.plain).flatMap { $0.isEmpty ? nil : $0 }
        metadata.developer = details.developers?.first { !$0.isEmpty }
        metadata.genres = details.genres?.map(\.description) ?? []
        metadata.tags = details.categories?.map(\.description) ?? []
        if details.releaseDate?.comingSoon != true {
            metadata.releaseDate = StoreReleaseDateParser.date(from: details.releaseDate?.date)
        }
        metadata.coverCandidates = SteamStoreEndpoint.libraryCapsules(appID: appID)
        metadata.heroCandidates = SteamStoreEndpoint.libraryHero(appID: appID)
            + [details.backgroundRaw, details.headerImage].compactMap { $0.flatMap(URL.init(string:)) }
        let screenshots = (details.screenshots ?? []).compactMap { $0.pathFull.flatMap(URL.init(string:)) }
        let thumbnails = (details.movies ?? []).compactMap { $0.thumbnail.flatMap(URL.init(string:)) }
        metadata.carouselImages = Array(screenshots.prefix(screenshotLimit))
            + Array(thumbnails.prefix(movieThumbnailLimit))
        return metadata
    }
}
