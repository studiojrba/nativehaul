import SwiftUI

/// Home (spec §3.1, note 14), from the real library: the hero carousel, Continue playing, the curated shelves (each
/// from real data, hidden below three games — ``HomeShelfCurator``) and the whole-shelf card. With nothing on the
/// shelf yet it says so kindly and offers the way in: build a first game, or add one (note 17).
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
    /// Opens Builds (to build a first game).
    var openBuilds: () -> Void = {}

    @State private var pageSize = CGSize.zero

    var body: some View {
        Group {
            if viewModel.isLibraryEmpty {
                EmptyStateView(
                    title: "Nothing built yet",
                    symbolName: "house",
                    message: "Let’s get your first game going so you can start playing. Build one of your Switch "
                        + "games, or add a game you already have."
                ) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button(BuildsCopy.emptyAction, systemImage: "sparkles", action: openBuilds)
                            .buttonStyle(EmberButtonStyle())
                        Button("Add Game", systemImage: "plus", action: addGame)
                    }
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
                ForEach(viewModel.shelves) { shelf in
                    HomeShelfRow(shelf: shelf, open: open)
                }
                WholeShelfCard(summary: viewModel.shelfSummary, action: seeAll)
                    .padding(.leading, ContentColumn(width: pageSize.width).leading)
                    .padding(.trailing, ContentColumn(width: pageSize.width).trailing)
                    .padding(.top, ShellLayout.WholeShelf.top)
            }
            .padding(.bottom, ShellLayout.Content.bottomPadding)
        }
        .scrollIndicators(.automatic)
        #if DEBUG
            .defaultScrollAnchor(ScreenshotRequest.current?.scrollsToEnd == true ? .bottom : .top)
        #endif
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
