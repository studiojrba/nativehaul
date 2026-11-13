import AppKit
import SwiftUI

/// The media set at the top of the details centre (ADR 0038): the trailer first when the game has one, then the hero
/// image (or the cover), then the screenshots, all images rendered from the local artwork cache. The frame takes each
/// slide's own shape, up to the dial's hero height, so a slide is never cropped. With nothing to show, a placeholder.
struct HeroMediaView: View {
    /// Hero image path.
    let heroImagePath: String?
    /// Cover path used when there is no hero image.
    let coverImagePath: String?
    /// Extra carousel slides.
    var carouselImagePaths: [String] = []
    /// Trailer stream URL, shown first.
    var trailerVideoURL: String?
    /// Trailer poster.
    var trailerPosterPath: String?
    @State private var index = 0
    @Environment(\.designIntensity) private var intensity

    var body: some View {
        Group {
            switch currentSlide {
            case let .trailer(.stream(url), posterPath):
                fitted(aspect: DesignTokens.Media.fallbackAspect) {
                    TrailerSlideView(url: url, posterPath: posterPath).id(url)
                }
            case let .trailer(.youTube(videoID), posterPath):
                fitted(aspect: DesignTokens.Media.fallbackAspect) {
                    YouTubeSlideView(videoID: videoID, posterPath: posterPath).id(videoID)
                }
            case let .image(path):
                if let image = NSImage(contentsOfFile: path) {
                    fitted(aspect: MediaFit.aspect(of: image.size) ?? DesignTokens.Media.fallbackAspect) {
                        Image(nsImage: image).resizable().scaledToFit()
                    }
                } else {
                    placeholder
                }
            case nil:
                placeholder
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func fitted(aspect: CGFloat, @ViewBuilder content: () -> some View) -> some View {
        FittedMediaFrame(aspect: aspect, maxHeight: heroHeight) {
            content()
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
                .overlay(alignment: .bottomTrailing) { slideControls }
        }
    }

    private var placeholder: some View {
        Theme.placeholder
            .frame(maxWidth: .infinity)
            .frame(height: heroHeight)
            .overlay {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(DesignTokens.Typography.largeTitle)
                    .foregroundStyle(Theme.secondaryText)
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(alignment: .bottomTrailing) { slideControls }
    }

    private var heroHeight: CGFloat {
        EnergyLevel.of(intensity).detailHeroHeight
    }

    @ViewBuilder private var slideControls: some View {
        if slides.count > 1 {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Button("Previous slide", systemImage: "chevron.left") { step(by: -1) }
                Text("\(min(index, slides.count - 1) + 1) / \(slides.count)")
                    .font(DesignTokens.Typography.monospacedSmall)
                Button("Next slide", systemImage: "chevron.right") { step(by: 1) }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .padding(DesignTokens.Spacing.sm)
            .smokedGlass(in: Capsule())
            .padding(DesignTokens.Spacing.md)
        }
    }

    private var slides: [MediaSlide] {
        MediaSlide.set(
            trailerURL: trailerVideoURL,
            trailerPosterPath: trailerPosterPath,
            heroImagePath: heroImagePath,
            coverImagePath: coverImagePath,
            carouselImagePaths: carouselImagePaths
        )
    }

    private var currentSlide: MediaSlide? {
        let slides = slides
        return slides.isEmpty ? nil : slides[min(index, slides.count - 1)]
    }

    private func step(by offset: Int) {
        let count = slides.count
        guard count > 0 else { return }
        index = (index + offset + count) % count
    }
}

#Preview {
    HeroMediaView(heroImagePath: nil, coverImagePath: nil)
        .padding(DesignTokens.Spacing.lg)
}
