import Foundation

/// Everything one provider found for a game. Empty values mean "not offered".
struct FetchedMetadata: Equatable, Sendable {
    /// The provider.
    let source: MetadataSource
    /// Plain-text description.
    var description: String?
    /// Developer studio (first listed when several).
    var developer: String?
    /// Genres.
    var genres: [String] = []
    /// Tags.
    var tags: [String] = []
    /// Release date.
    var releaseDate: Date?
    /// Portrait cover candidates, best first.
    var coverCandidates: [URL] = []
    /// Hero/banner candidates, best first.
    var heroCandidates: [URL] = []
    /// Carousel slides (screenshots, trailer thumbnails), in display order.
    var carouselImages: [URL] = []

    /// Creates an empty result for `source`.
    init(source: MetadataSource) {
        self.source = source
    }

    /// Whether this result offers a value for `field`.
    func offers(_ field: MetadataField) -> Bool {
        switch field {
        case .description: description?.isEmpty == false
        case .developer: developer?.isEmpty == false
        case .genres: !genres.isEmpty
        case .tags: !tags.isEmpty
        case .releaseDate: releaseDate != nil
        case .cover: !coverCandidates.isEmpty
        case .hero: !heroCandidates.isEmpty
        case .carousel: !carouselImages.isEmpty
        }
    }
}
