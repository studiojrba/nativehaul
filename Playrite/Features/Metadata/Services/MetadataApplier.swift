import Foundation

/// Writes a ``MetadataUpdate`` into a game and records provenance. Touches only metadata fields — playtime, status,
/// sessions and tracking are never changed.
@MainActor
enum MetadataApplier {
    /// Applies `update` to `game`.
    static func apply(_ update: MetadataUpdate, to game: Game) {
        if let description = update.description {
            game.summary = description
        }
        if let developer = update.developer {
            game.developer = developer
        }
        if let genres = update.genres {
            game.genres = genres
        }
        if let tags = update.tags {
            game.tags = tags
        }
        if let releaseDate = update.releaseDate {
            game.releaseDate = releaseDate
        }
        if let coverPath = update.coverPath {
            game.coverImagePath = coverPath
        }
        if let heroPath = update.heroPath {
            game.heroImagePath = heroPath
        }
        if let carouselPaths = update.carouselPaths {
            game.carouselImagePaths = carouselPaths
        }
        var provenance = game.metadataProvenance
        for field in update.fields {
            provenance[field] = update.sources[field]
        }
        game.metadataProvenance = provenance
    }
}
