import SwiftUI

/// The detail screen's media (ADR 0052), reusing the Builds page pieces: the trailer first when the game has one,
/// otherwise the Builds showcase slideshow of its screenshots (or its hero as a still).
struct TVGameMediaView: View {
    /// The game.
    let game: Game
    /// Tallest the media may be.
    let maxHeight: CGFloat

    var body: some View {
        if let trailer = GameTrailer(storedURL: game.trailerVideoURL) {
            FittedMediaFrame(aspect: DesignTokens.Media.fallbackAspect, maxHeight: maxHeight) {
                Group {
                    switch trailer {
                    case let .stream(url): TrailerSlideView(url: url, posterPath: game.trailerPosterPath)
                    case let .youTube(videoID): YouTubeSlideView(videoID: videoID, posterPath: game.trailerPosterPath)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            }
        } else if let showcase = BuildShowcase.make(screenshots: game.carouselImagePaths, hero: game.heroImagePath) {
            BuildShowcaseView(showcase: showcase, maxHeight: maxHeight)
        } else {
            CoverArtView(imagePath: game.coverImagePath, title: game.title)
                .frame(height: maxHeight)
        }
    }
}

#Preview {
    TVGameMediaView(game: Game(title: "Tideborn"), maxHeight: DesignTokens.Media.showcaseMaxHeight)
        .padding(DesignTokens.Spacing.xl)
}
