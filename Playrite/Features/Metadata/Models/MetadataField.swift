import Foundation

/// A metadata field that a provider can fill and whose provenance is recorded per game.
enum MetadataField: String, Codable, CaseIterable, Sendable {
    /// Game description (``Game/summary``).
    case description
    /// Developer studio.
    case developer
    /// Genres.
    case genres
    /// Tags (Steam categories, for example).
    case tags
    /// Original release date.
    case releaseDate
    /// Portrait cover art.
    case cover
    /// Wide hero/banner art.
    case hero
    /// Hero carousel slides.
    case carousel

    /// The artwork kind for an art field, or `nil` for a text field.
    var artworkKind: ArtworkKind? {
        switch self {
        case .cover: .cover
        case .hero: .hero
        case .carousel: .carousel
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
        }
    }
}
