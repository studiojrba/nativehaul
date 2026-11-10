import Foundation

/// The fields a pass will write for one game, each with the source that supplied it.
struct MetadataUpdate: Equatable, Sendable {
    /// Description.
    var description: String?
    /// Developer.
    var developer: String?
    /// Genres.
    var genres: [String]?
    /// Tags.
    var tags: [String]?
    /// Release date.
    var releaseDate: Date?
    /// Cached cover path.
    var coverPath: String?
    /// Cached hero path.
    var heroPath: String?
    /// Cached carousel paths.
    var carouselPaths: [String]?
    /// Trailer stream URL.
    var trailerVideoURL: String?
    /// Cached trailer poster path.
    var trailerPosterPath: String?
    /// Source per filled field.
    private(set) var sources: [MetadataField: MetadataSource] = [:]

    /// Creates an empty update.
    init() {}

    /// Fields filled so far.
    var fields: Set<MetadataField> {
        Set(sources.keys)
    }

    /// Whether nothing was filled.
    var isEmpty: Bool {
        sources.isEmpty
    }

    /// Takes every text field in `allowed` that `metadata` offers and this update doesn't have yet.
    mutating func takeText(from metadata: FetchedMetadata, allowed: Set<MetadataField>) {
        let open = allowed.subtracting(fields)
        func wants(_ field: MetadataField) -> Bool {
            open.contains(field) && metadata.offers(field)
        }
        if wants(.description) {
            description = metadata.description
            sources[.description] = metadata.source
        }
        if wants(.developer) {
            developer = metadata.developer
            sources[.developer] = metadata.source
        }
        if wants(.genres) {
            genres = metadata.genres
            sources[.genres] = metadata.source
        }
        if wants(.tags) {
            tags = metadata.tags
            sources[.tags] = metadata.source
        }
        if wants(.releaseDate) {
            releaseDate = metadata.releaseDate
            sources[.releaseDate] = metadata.source
        }
    }

    /// Records a trailer (its poster may be missing; the media set then shows a plain play button).
    mutating func setTrailer(videoURL: URL, posterPath: String?, source: MetadataSource) {
        trailerVideoURL = videoURL.absoluteString
        trailerPosterPath = posterPath
        sources[.trailer] = source
    }

    /// Records a cached image for an art field.
    mutating func setArtwork(_ field: MetadataField, paths: [String], source: MetadataSource) {
        guard let first = paths.first else { return }
        switch field {
        case .cover: coverPath = first
        case .hero: heroPath = first
        case .carousel: carouselPaths = paths
        case .description, .developer, .genres, .tags, .releaseDate, .trailer: return
        }
        sources[field] = source
    }
}
