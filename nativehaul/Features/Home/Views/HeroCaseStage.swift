import SwiftUI

/// The hero's standing case and its switch choreography (spec §4.1): the outgoing case slides away to the right while
/// the incoming one slides in from the same side and settles into its tilt (``CaseChoreography``). The case is the only
/// thing that slides. Hovering turns it toward the viewer.
struct HeroCaseStage: View {
    /// Home's state.
    let viewModel: HomeViewModel
    /// The slides.
    let slides: [HeroSlide]
    /// How far the cases travel (62% of the window width).
    let travel: CGFloat
    /// Turned toward the viewer.
    let isTurned: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var carousel: HeroCarousel {
        viewModel.carousel
    }

    var body: some View {
        let started = carousel.switchStartedAt
        let isSettled = carousel.leaving == nil
            && CaseChoreography.isSettled(elapsed: Date().timeIntervalSince(started), reduceMotion: reduceMotion)
        TimelineView(.animation(paused: isSettled)) { context in
            let elapsed = context.date.timeIntervalSince(started)
            ZStack {
                if let leaving = carousel.leaving, slides.indices.contains(leaving) {
                    standingCase(slides[leaving], pose: CaseChoreography.outgoing(
                        elapsed: elapsed,
                        travel: travel,
                        reduceMotion: reduceMotion
                    ))
                    .id("out-\(carousel.turn)")
                }
                if slides.indices.contains(carousel.index) {
                    standingCase(slides[carousel.index], pose: CaseChoreography.incoming(
                        elapsed: elapsed,
                        travel: travel,
                        reduceMotion: reduceMotion
                    ))
                    .id("in-\(carousel.turn)")
                }
            }
        }
    }

    private func standingCase(_ slide: HeroSlide, pose: CasePose) -> some View {
        StandingCase(
            coverPath: slide.game.coverImagePath,
            title: slide.game.title,
            palette: viewModel.palette(for: slide.game),
            isTurned: isTurned
        )
        .rotationEffect(.degrees(pose.rotation))
        .offset(x: pose.x)
        .opacity(pose.opacity)
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let viewModel = HomeViewModel(
        library: environment.makeLibraryViewModel(),
        paletteExtractor: MockGamePaletteExtractor()
    )
    AppearancePreviewPair {
        HeroCaseStage(viewModel: viewModel, slides: viewModel.slides, travel: 0, isTurned: false)
            .frame(width: DesignTokens.Cover.detailWidth)
            .padding(KitMetrics.Spacing.page)
    }
}
