import Foundation

/// Pure mapping from a Steam store `appdetails` payload to ``FetchedMetadata``.
enum SteamStoreMetadataMapper {
    /// Most screenshots kept for the carousel.
    static let screenshotLimit = 8

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
        metadata.carouselImages = Array(screenshots.prefix(screenshotLimit))
        metadata.trailer = trailer(from: details.movies ?? [], screenshots: screenshots)
        return metadata
    }

    /// The trailer (ADR 0038): Steam's highlighted movie, else its first, played from its stream. Its poster is the
    /// first full-size screenshot, since Steam's own thumbnail is only 293×165, then that thumbnail.
    private static func trailer(from movies: [SteamStoreMovie], screenshots: [URL]) -> TrailerCandidate? {
        let playable = movies.filter { $0.streamURL != nil }
        guard let movie = playable.first(where: { $0.highlight == true }) ?? playable.first,
              let stream = movie.streamURL
        else { return nil }
        let thumbnail = [movie.thumbnail].compactMap { $0.flatMap(URL.init(string:)) }
        return TrailerCandidate(videoURL: stream, posterCandidates: Array(screenshots.prefix(1)) + thumbnail)
    }
}
