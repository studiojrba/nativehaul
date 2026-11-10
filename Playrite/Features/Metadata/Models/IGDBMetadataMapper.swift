import Foundation

/// Pure mapping from an IGDB game to ``FetchedMetadata`` (ADR 0038): the summary, 1080p screenshots, and the first
/// video as a YouTube trailer.
enum IGDBMetadataMapper {
    /// Most screenshots kept for the slideshow.
    static let screenshotLimit = 8

    /// Metadata for `game`.
    static func metadata(from game: IGDBGame) -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .igdb)
        let summary = game.summary?.trimmingCharacters(in: .whitespacesAndNewlines)
        metadata.description = summary?.isEmpty == false ? summary : nil
        metadata.carouselImages = Array((game.screenshots ?? []).compactMap {
            $0.imageId.flatMap(IGDBEndpoint.screenshot(imageID:))
        }.prefix(screenshotLimit))
        metadata.trailer = trailer(from: game)
        return metadata
    }

    /// The first video with a usable YouTube ID, as a watch URL with YouTube's poster stills.
    private static func trailer(from game: IGDBGame) -> TrailerCandidate? {
        guard let videoID = game.videos?.lazy.compactMap(\.videoId).first(where: YouTubeEmbed.isValidVideoID),
              let watch = IGDBEndpoint.youTubeWatch(videoID: videoID)
        else { return nil }
        return TrailerCandidate(videoURL: watch, posterCandidates: IGDBEndpoint.youTubePosters(videoID: videoID))
    }
}
