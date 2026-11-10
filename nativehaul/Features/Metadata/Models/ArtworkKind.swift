import Foundation

/// The kinds of artwork nativehaul stores per game. All are cached on disk, never hotlinked.
enum ArtworkKind: String, Codable, CaseIterable, Sendable {
    /// Portrait cover (grid poster), roughly 2:3.
    case cover
    /// Wide hero/banner for the top of the details screen.
    case hero
    /// Extra slides for the hero carousel (screenshots, trailer thumbnails).
    case carousel
    /// Poster still shown before a trailer plays (and instead of it under Reduce Motion).
    case trailerPoster
}
