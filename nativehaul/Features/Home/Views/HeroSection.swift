import SwiftUI

/// The Home hero carousel (spec §3.1, §4.1): one slide per Jump Back In game over the active game's wash, text on the
/// left and the standing case on the right, looping chevrons at the edges, ←/→ keys, auto-advance every 7s (restarted
/// by any switch, paused on hover). Tapping the case opens the incoming game's Detail. The sliding case is clipped to
/// the section; the wash is not, so it fades out below the hero instead of ending on a hard edge.
struct HeroSection: View {
    /// Home's state.
    let viewModel: HomeViewModel
    /// The slides.
    let slides: [HeroSlide]
    /// The page's size (for `vw` / `vh` metrics).
    let pageSize: CGSize
    /// Plays a game.
    let play: (Game) -> Void
    /// Opens a game's Detail.
    let open: (Game) -> Void

    @State private var isCaseHovered = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeTokens) private var tokens

    private var carousel: HeroCarousel {
        viewModel.carousel
    }

    var body: some View {
        let column = ContentColumn(width: pageSize.width)
        HStack(alignment: .center, spacing: ShellLayout.Hero.columnGap) {
            HeroTextColumn(viewModel: viewModel, slides: slides, headlineSize: headlineSize, play: play, open: open)
                .frame(width: textColumnWidth(column), alignment: .leading)
            caseButton
                .frame(maxWidth: ShellLayout.Hero.caseMaxWidth)
                .frame(maxWidth: .infinity)
        }
        .padding(.leading, column.leading)
        .padding(.trailing, column.trailing)
        .padding(.top, ShellLayout.Hero.topPadding)
        .frame(maxWidth: .infinity, minHeight: pageSize.height * ShellLayout.Hero.minHeightShare)
        .overlay { chevrons }
        .clipped()
        .background { wash }
        .contentShape(Rectangle())
        .onHover { carousel.isHovered = $0 }
        .task(id: carousel.autoAdvanceKey) { await carousel.runAutoAdvance() }
        .onArrowKeys(left: { carousel.previous() }, right: { carousel.next() })
    }

    private var headlineSize: CGFloat {
        TypeStyle.clampedDisplay(
            width: pageSize.width,
            min: TypeStyle.DisplaySize.heroMin,
            share: TypeStyle.DisplaySize.heroWidthShare,
            max: TypeStyle.DisplaySize.heroMax
        )
    }

    private func textColumnWidth(_ column: ContentColumn) -> CGFloat {
        let available = column.contentWidth(in: pageSize.width) - ShellLayout.Hero.columnGap
        return max(0, available * ShellLayout.Hero.textColumnShare)
    }

    private var caseButton: some View {
        Button {
            if slides.indices.contains(carousel.index) {
                open(slides[carousel.index].game)
            }
        } label: {
            HeroCaseStage(
                viewModel: viewModel,
                slides: slides,
                travel: pageSize.width * HeroTiming.caseTravelShare,
                isTurned: isCaseHovered
            )
        }
        .buttonStyle(.plain)
        .pointerStyle(.link)
        .onHover { isCaseHovered = $0 }
        .accessibilityLabel(slides.indices.contains(carousel.index) ? "About \(slides[carousel.index].game.title)" : "")
    }

    private var wash: some View {
        let tones = GameTones(scheme: colorScheme)
        let game = slides.indices.contains(carousel.index) ? slides[carousel.index].game : nil
        let gameWash = tones.wash(game.map(viewModel.palette(for:)) ?? .neutral)
        return WashBackground(colors: [gameWash, tokens.wash(.sky), tokens.wash(.cream)], crossfade: HeroTiming.wash)
    }

    @ViewBuilder private var chevrons: some View {
        if slides.count > 1 {
            ZStack {
                ChevronButton(direction: .leading, size: KitMetrics.Chevron.heroSize) { carousel.previous() }
                    .accessibilityLabel("Previous game")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, ShellLayout.Hero.chevronLeading)
                ChevronButton(direction: .trailing, size: KitMetrics.Chevron.heroSize) { carousel.next() }
                    .accessibilityLabel("Next game")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, ShellLayout.Hero.chevronTrailing)
            }
            .offset(y: ShellLayout.Hero.chevronDrop)
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let viewModel = HomeViewModel(
        library: environment.makeLibraryViewModel(),
        paletteExtractor: MockGamePaletteExtractor()
    )
    HeroSection(
        viewModel: viewModel,
        slides: viewModel.slides,
        pageSize: CGSize(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight),
        play: { _ in },
        open: { _ in }
    )
}
