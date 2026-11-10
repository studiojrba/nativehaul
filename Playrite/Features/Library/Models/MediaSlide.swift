import Foundation

/// One item in a game's media set (ADR 0038).
enum MediaSlide: Equatable, Sendable {
    /// The trailer, with its cached poster.
    case trailer(GameTrailer, posterPath: String?)
    /// A cached image (hero, cover or screenshot).
    case image(String)

    /// The media set, in order: the trailer first when there is one, then the hero (or the cover when there is no
    /// hero), then the screenshots.
    static func set(
        trailerURL: String?,
        trailerPosterPath: String?,
        heroImagePath: String?,
        coverImagePath: String?,
        carouselImagePaths: [String]
    ) -> [MediaSlide] {
        let trailer = GameTrailer(storedURL: trailerURL).map { MediaSlide.trailer($0, posterPath: trailerPosterPath) }
        let images = ([heroImagePath ?? coverImagePath].compactMap(\.self) + carouselImagePaths).map(MediaSlide.image)
        return [trailer].compactMap(\.self) + images
    }
}
