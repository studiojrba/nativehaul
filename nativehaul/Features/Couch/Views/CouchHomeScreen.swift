import SwiftUI

/// Couch Home (spec §3.7): the hero zone (words on the left, the standing case on the right in its focused pose when
/// the hero has focus, looping arrows as their own focus row) over the shelves viewport. The hero carousel is the
/// desktop's, shared. An empty library says so and points to the desk.
struct CouchHomeScreen: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    private typealias Metrics = CouchLayout.Hero

    var body: some View {
        let scale = viewModel.scale
        let slides = viewModel.home.slides
        ZStack(alignment: .topLeading) {
            if slides.isEmpty {
                CouchEmptyState(
                    title: "Your shelf is empty",
                    message: "Add games at the desk, and they'll be here on the sofa.",
                    scale: scale
                )
            } else {
                CouchHeroText(viewModel: viewModel)
                    .padding(.leading, scale(CouchLayout.gutter))
                    .padding(.top, scale.height(Metrics.topShare))
                heroCase(slides: slides, scale: scale)
                if slides.count > 1 {
                    heroArrows(scale: scale)
                }
            }
            CouchShelvesViewport(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { viewModel.home.carousel.update(count: slides.count) }
        .onChange(of: slides.map(\.id)) { _, ids in viewModel.home.carousel.update(count: ids.count) }
        .task(id: slides.map(\.id)) { await viewModel.home.loadPalettes() }
    }

    private func heroCase(slides: [HeroSlide], scale: CouchScale) -> some View {
        let isFocused = viewModel.state.home.row == CouchHomeFocus.heroRow && viewModel.state.area == .content
        return Button {
            viewModel.heroCaseClicked()
        } label: {
            HeroCaseStage(
                viewModel: viewModel.home,
                slides: slides,
                travel: scale.width(HeroTiming.caseTravelShare),
                isTurned: isFocused
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.heroGame.map { "Play \($0.title)" } ?? "")
        .frame(width: scale.height(Metrics.caseWidthShare))
        .padding(.top, scale.height(Metrics.caseTopShare))
        .padding(.trailing, scale.width(Metrics.caseRightShare))
        .frame(maxWidth: .infinity, alignment: .topTrailing)
    }

    private func heroArrows(scale: CouchScale) -> some View {
        let isRow = viewModel.state.home.row == CouchHomeFocus.heroArrowsRow && viewModel.state.area == .content
        let arrow = viewModel.state.home.heroArrow
        return HStack {
            ChevronButton(direction: .leading, size: scale(Metrics.arrowSize), isFocused: isRow && arrow == .left) {
                viewModel.home.carousel.previous()
            }
            .accessibilityLabel("Previous game")
            Spacer(minLength: 0)
            ChevronButton(direction: .trailing, size: scale(Metrics.arrowSize), isFocused: isRow && arrow == .right) {
                viewModel.home.carousel.next()
            }
            .accessibilityLabel("Next game")
        }
        .padding(.horizontal, scale(Metrics.arrowInset))
        .padding(.top, scale.height(Metrics.arrowTopShare))
    }
}

#Preview {
    CouchHomeScreen(viewModel: .preview)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
