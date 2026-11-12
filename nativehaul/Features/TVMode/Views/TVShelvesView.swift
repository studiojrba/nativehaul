import SwiftUI

/// The default layout (ADR 0052): one horizontal row per shelf, stacked; the focused row and tile scroll into view.
struct TVShelvesView: View {
    /// TV state.
    let viewModel: TVModeViewModel
    /// Screen metrics.
    let metrics: TVMetrics

    var body: some View {
        ScrollViewReader { vertical in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: metrics.gap) {
                    ForEach(Array(viewModel.shelves.enumerated()), id: \.element.id) { shelfIndex, shelf in
                        VStack(alignment: .leading, spacing: metrics.halfGap) {
                            Text(shelf.title)
                                .font(metrics.bodyEmphasisFont)
                                .foregroundStyle(Theme.secondaryText)
                            row(shelf, shelfIndex: shelfIndex)
                        }
                        .id(shelf.id)
                    }
                }
                .padding(.vertical, metrics.focusShadowRadius)
            }
            .scrollIndicators(.never)
            .scrollDisabled(true)
            .onChange(of: viewModel.focus.shelf) { _, shelf in
                guard viewModel.shelves.indices.contains(shelf) else { return }
                withAnimation(.easeOut(duration: DesignTokens.TVMode.focusAnimation)) {
                    vertical.scrollTo(viewModel.shelves[shelf].id, anchor: .top)
                }
            }
        }
    }

    private func row(_ shelf: TVShelf, shelfIndex: Int) -> some View {
        ScrollViewReader { horizontal in
            ScrollView(.horizontal) {
                LazyHStack(spacing: metrics.gap) {
                    ForEach(Array(shelf.games.enumerated()), id: \.element.id) { index, game in
                        TVTileView(
                            game: game,
                            isFocused: viewModel.focus == TVFocus(shelf: shelfIndex, item: index),
                            height: metrics.tileHeight(.shelf),
                            metrics: metrics
                        )
                        .id(game.id)
                    }
                }
                .padding(.vertical, metrics.focusShadowRadius)
                .padding(.horizontal, metrics.focusShadowRadius)
            }
            .scrollIndicators(.never)
            .scrollDisabled(true)
            .onChange(of: viewModel.focus) { _, focus in
                guard focus.shelf == shelfIndex, shelf.games.indices.contains(focus.item) else { return }
                withAnimation(.easeOut(duration: DesignTokens.TVMode.focusAnimation)) {
                    horizontal.scrollTo(shelf.games[focus.item].id, anchor: .center)
                }
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let viewModel = environment.makeTVModeViewModel()
    TVShelvesView(viewModel: viewModel, metrics: TVMetrics(size: DesignTokens.TVMode.previewScreen))
        .onAppear { viewModel.reload() }
        .background(Theme.canvas)
}
