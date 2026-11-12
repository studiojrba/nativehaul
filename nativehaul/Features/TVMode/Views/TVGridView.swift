import SwiftUI

/// The optional grid layout (ADR 0052): the current shelf as a grid; LB/RB switch shelves.
struct TVGridView: View {
    /// TV state.
    let viewModel: TVModeViewModel
    /// Screen metrics.
    let metrics: TVMetrics

    var body: some View {
        let columns = Array(
            repeating: GridItem(.fixed(metrics.tileWidth(.grid)), spacing: metrics.gap),
            count: metrics.gridColumns
        )
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                if viewModel.shelves.indices.contains(viewModel.focus.shelf) {
                    let shelf = viewModel.shelves[viewModel.focus.shelf]
                    LazyVGrid(columns: columns, alignment: .leading, spacing: metrics.gap) {
                        ForEach(Array(shelf.games.enumerated()), id: \.element.id) { index, game in
                            TVTileView(
                                game: game,
                                isFocused: viewModel.focus.item == index,
                                height: metrics.tileHeight(.grid),
                                metrics: metrics
                            )
                            .id(game.id)
                        }
                    }
                    .padding(metrics.focusShadowRadius)
                }
            }
            .scrollIndicators(.never)
            .scrollDisabled(true)
            .onChange(of: viewModel.focus) { _, focus in
                guard let game = viewModel.focusedGame, focus.item >= 0 else { return }
                withAnimation(.easeOut(duration: DesignTokens.TVMode.focusAnimation)) {
                    proxy.scrollTo(game.id, anchor: .center)
                }
            }
        }
        .onAppear { viewModel.gridColumns = metrics.gridColumns }
        .onChange(of: metrics) { viewModel.gridColumns = metrics.gridColumns }
    }
}

#Preview {
    let viewModel = AppEnvironment.preview.makeTVModeViewModel()
    TVGridView(viewModel: viewModel, metrics: TVMetrics(size: DesignTokens.TVMode.previewScreen))
        .onAppear { viewModel.reload() }
        .background(Theme.canvas)
}
