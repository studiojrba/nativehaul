import Foundation

/// One item in a game's media set (ADR 0038).
enum MediaSlide: Equatable, Sendable {
    /// The trailer, with its cached poster.
    case trailer(GameTrailer, posterPath: String?)
    /// A cached image (hero, cover or screenshot).
    case image(String)

    /// The media set, in order: the trailer first when there is one, then the hero (or the cover when there is no
    /// hero) unless `includingArt` is false (the detail page prints those on its game case, ADR 0039), then the
    /// screenshots.
    static func set(
        trailerURL: String?,
        trailerPosterPath: String?,
        heroImagePath: String?,
        coverImagePath: String?,
        carouselImagePaths: [String],
        includingArt: Bool = true
    ) -> [MediaSlide] {
        let trailer = GameTrailer(storedURL: trailerURL).map { MediaSlide.trailer($0, posterPath: trailerPosterPath) }
        let art = includingArt ? [heroImagePath ?? coverImagePath].compactMap(\.self) : []
        let images = (art + carouselImagePaths).map(MediaSlide.image)
        return [trailer].compactMap(\.self) + images
    }
}
