import SwiftUI

/// Couch Library (ADR 0058, undesigned — derived): the whole shelf A–Z as a grid of couch tiles at 10-foot scale. The
/// D-pad moves in reading order and the grid scrolls to keep the focused tile in view; ZL/ZR jump by letter.
struct CouchLibraryScreen: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let scale = viewModel.scale
        let games = viewModel.libraryGames
        let columns = Array(
            repeating: GridItem(
                .fixed(scale(CouchLayout.Shelves.tileWidth)),
                spacing: scale(CouchLayout.Shelves.tileGap)
            ),
            count: scale.visibleTiles
        )
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: scale(CouchLayout.Page.contentTop)) {
                    CouchPageHeader(
                        eyebrow: "Library",
                        title: "Your shelf.",
                        subtitle: "\(ShelfSummary(games: games).gamesPhrase), A–Z",
                        scale: scale
                    )
                    LazyVGrid(columns: columns, alignment: .leading, spacing: scale(CouchLayout.Library.rowGap)) {
                        ForEach(Array(games.enumerated()), id: \.element.id) { offset, game in
                            CouchTile(game: game, isFocused: isFocused(offset), scale: scale).id(game.id)
                        }
                    }
                }
                .padding(.horizontal, scale(CouchLayout.gutter))
                .padding(.top, scale(CouchLayout.Page.top))
                .padding(.bottom, scale(CouchLayout.Page.bottomClearance))
            }
            .scrollIndicators(.never)
            .scrollDisabled(true)
            .onChange(of: viewModel.state.libraryIndex) { _, index in
                guard let game = games[safe: index] else { return }
                withAnimation(reduceMotion ? nil : Motion.settle(Motion.Duration.rise)) {
                    proxy.scrollTo(game.id, anchor: .center)
                }
            }
        }
    }

    private func isFocused(_ offset: Int) -> Bool {
        viewModel.state.area == .content && viewModel.state.libraryIndex == offset
    }
}

#Preview {
    let viewModel = CouchViewModel.preview
    viewModel.state.screen = .library
    return CouchLibraryScreen(viewModel: viewModel)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
