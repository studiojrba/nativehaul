import SwiftUI

/// Home (spec §3.1), from the real library: the hero carousel, Continue playing and the whole-shelf card. The curated
/// shelves ("Cosy for tonight", "Bring a friend") are not shown: nothing in the library says which games belong on
/// them, and membership is never faked. An empty library offers Add Game instead.
struct HomeScreen: View {
    /// Home's state.
    let viewModel: HomeViewModel
    /// Plays a game.
    let play: (Game) -> Void
    /// Opens a game's Detail.
    let open: (Game) -> Void
    /// Goes to Library.
    let seeAll: () -> Void
    /// Opens Add Game.
    let addGame: () -> Void

    @State private var pageSize = CGSize.zero

    var body: some View {
        Group {
            if viewModel.isLibraryEmpty {
                EmptyStateView(
                    title: "Your shelf is empty",
                    symbolName: "house",
                    message: "Add a game, or let nativehaul find the ones already on your Mac."
                ) {
                    Button("Add Game", systemImage: "plus", action: addGame)
                }
            } else {
                page
            }
        }
        .onGeometryChange(for: CGSize.self) { $0.size } action: { pageSize = $0 }
    }

    private var page: some View {
        let slides = viewModel.slides
        return ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                if !slides.isEmpty {
                    HeroSection(viewModel: viewModel, slides: slides, pageSize: pageSize, play: play, open: open)
                }
                ContinueSection(viewModel: viewModel, pageWidth: pageSize.width, play: play, open: open)
                WholeShelfCard(summary: viewModel.shelfSummary, action: seeAll)
                    .padding(.leading, ContentColumn(width: pageSize.width).leading)
                    .padding(.trailing, ContentColumn(width: pageSize.width).trailing)
                    .padding(.top, ShellLayout.WholeShelf.top)
            }
            .padding(.bottom, ShellLayout.Content.bottomPadding)
        }
        .scrollIndicators(.automatic)
        .onAppear { viewModel.carousel.update(count: slides.count) }
        .onChange(of: slides.map(\.id)) { _, ids in viewModel.carousel.update(count: ids.count) }
        .task(id: slides.map(\.id)) { await viewModel.loadPalettes() }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    HomeScreen(
        viewModel: HomeViewModel(
            library: environment.makeLibraryViewModel(),
            paletteExtractor: MockGamePaletteExtractor()
        ),
        play: { _ in },
        open: { _ in },
        seeAll: {},
        addGame: {}
    )
    .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
