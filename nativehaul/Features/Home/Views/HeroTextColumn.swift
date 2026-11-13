import SwiftUI

/// The hero's left column (spec §4.1): every slide's text shares one cell, so the block keeps the height of the tallest
/// slide and nothing below moves; only the shown slide is visible and live. Switching fades the text out (350ms), swaps
/// it, and fades it back in (450ms) — it never slides. The dots sit underneath.
struct HeroTextColumn: View {
    /// Home's state.
    let viewModel: HomeViewModel
    /// The slides.
    let slides: [HeroSlide]
    /// Headline size.
    let headlineSize: CGFloat
    /// Plays a game.
    let play: (Game) -> Void
    /// Opens a game's Detail.
    let open: (Game) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var carousel: HeroCarousel {
        viewModel.carousel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { offset, slide in
                    let isShown = offset == carousel.shown
                    HeroSlideText(
                        slide: slide,
                        playLabel: viewModel.playLabel(for: slide.game),
                        headlineSize: headlineSize,
                        play: { play(slide.game) },
                        open: { open(slide.game) }
                    )
                    .opacity(isShown ? 1 : 0)
                    .allowsHitTesting(isShown && carousel.isTextVisible)
                    .accessibilityHidden(!isShown)
                }
            }
            .opacity(carousel.isTextVisible ? 1 : 0)
            .animation(textAnimation, value: carousel.isTextVisible)
            if slides.count > 1 {
                CarouselDots(
                    count: slides.count,
                    index: carousel.index,
                    label: { "Show \(slides[$0].copy.emphasis)" },
                    select: { carousel.go(to: $0) }
                )
                .padding(.leading, -ShellLayout.Hero.dotHitPadding)
                .padding(.top, ShellLayout.Hero.dotsTop)
            }
        }
        .riseIn()
    }

    private var textAnimation: Animation {
        .easeOut(duration: carousel.isTextVisible ? HeroTiming.textIn : HeroTiming.textOut)
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let viewModel = HomeViewModel(
        library: environment.makeLibraryViewModel(),
        paletteExtractor: MockGamePaletteExtractor()
    )
    AppearancePreviewPair {
        HeroTextColumn(
            viewModel: viewModel,
            slides: viewModel.slides,
            headlineSize: TypeStyle.DisplaySize.heroMin,
            play: { _ in },
            open: { _ in }
        )
        .padding(KitMetrics.Spacing.section)
    }
}
