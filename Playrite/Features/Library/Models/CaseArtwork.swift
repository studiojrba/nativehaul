import Foundation

/// What is printed on a game's case (ADR 0039): the cover on the front, the hero (or a screenshot) on the back, and
/// the title on the spine. Retriever caches no logo art yet, so every spine prints the title.
struct CaseArtwork: Equatable, Sendable {
    /// Cover art for the front.
    let frontPath: String
    /// Art for the back, when the game has any.
    let backPath: String?
    /// Text on the spine.
    let spineTitle: String

    /// The case for `game`, or `nil` when it has no readable cover (the page then shows a plain media panel).
    @MainActor
    static func make(
        for game: Game,
        fileExists: (String) -> Bool = FileManager.default.fileExists(atPath:)
    ) -> CaseArtwork? {
        guard let cover = game.coverImagePath, fileExists(cover) else { return nil }
        let back = ([game.heroImagePath] + game.carouselImagePaths.map(Optional.some))
            .compactMap(\.self).first(where: fileExists)
        return CaseArtwork(frontPath: cover, backPath: back, spineTitle: game.title)
    }
}
