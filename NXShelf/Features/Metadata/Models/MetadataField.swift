import Foundation

/// A metadata field that a provider can fill and whose provenance is recorded per game.
enum MetadataField: String, Codable, CaseIterable, Sendable {
    /// Game description (``Game/summary``).
    case description
    /// Developer studio.
    case developer
    /// Genres.
    case genres
    /// Tags (features and categories).
    case tags
    /// Original release date.
    case releaseDate
    /// Portrait cover art.
    case cover
    /// Wide hero/banner art.
    case hero
    /// Hero carousel slides.
    case carousel
    /// Trailer video, streamed (ADR 0038); its poster is cached art.
    case trailer

    /// The artwork kind for an art field, or `nil` for a text field.
    var artworkKind: ArtworkKind? {
        switch self {
        case .cover: .cover
        case .hero: .hero
        case .carousel: .carousel
        case .trailer: .trailerPoster
        case .description, .developer, .genres, .tags, .releaseDate: nil
        }
    }

    /// Whether this field is an image.
    var isArtwork: Bool {
        artworkKind != nil
    }

    /// Label for the Manage sheet.
    var displayName: String {
        switch self {
        case .description: "Description"
        case .developer: "Developer"
        case .genres: "Genres"
        case .tags: "Tags"
        case .releaseDate: "Release Date"
        case .cover: "Cover"
        case .hero: "Hero"
        case .carousel: "Carousel"
        case .trailer: "Trailer"
        }
    }
}
