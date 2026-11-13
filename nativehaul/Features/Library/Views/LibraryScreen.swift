import SwiftUI

/// Library (spec §3.2): "Your shelf." over a mint and blush wash, the sort pill, and an adaptive grid of covers that
/// rise in, staggered, again whenever the sort changes. The menu bar's Library filters narrow it (a chip says so and
/// clears them). Tapping a card opens Detail; its context menu keeps Play, Set Status and Remove.
struct LibraryScreen: View {
    /// The shared library.
    @Bindable var viewModel: LibraryViewModel
    /// A game's build badge.
    let badge: (Game) -> LibraryBuildBadge?
    /// Opens a game's Detail.
    let open: (Game) -> Void
    /// Plays a game.
    let play: (Game) -> Void
    /// Opens Add Game.
    let addGame: () -> Void
    /// Reference time.
    var now: Date = .now

    @State private var pageWidth: CGFloat = 0

    var body: some View {
        Group {
            if viewModel.games.isEmpty {
                EmptyStateView(
                    title: "Your shelf is empty",
                    symbolName: "square.grid.2x2",
                    message: "Add your game folders, or import a library file."
                ) {
                    Button("Add Game", systemImage: "plus", action: addGame)
                }
            } else {
                page
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { pageWidth = $0 }
    }

    private var page: some View {
        let column = ContentColumn(width: pageWidth)
        let games = viewModel.shelfGames
        return ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                LibraryHeader(summary: ShelfSummary(games: games), sort: $viewModel.sort, pageWidth: pageWidth)
                if viewModel.isFiltered {
                    filterChip
                        .padding(.top, DesignTokens.Spacing.lg)
                }
                grid(games)
                    .padding(.top, ShellLayout.Library.gridTop)
            }
            .padding(.leading, column.leading)
            .padding(.trailing, column.trailing)
            .padding(.top, ShellLayout.Library.topPadding)
            .padding(.bottom, ShellLayout.Content.bottomPadding)
            .background(alignment: .top) {
                WashBackground(slots: [.mint, .blush])
                    .frame(height: ShellLayout.Library.washHeight)
            }
        }
    }

    private func grid(_ games: [Game]) -> some View {
        LazyVGrid(
            columns: [GridItem(
                .adaptive(minimum: ShellLayout.Library.minimumCardWidth),
                spacing: ShellLayout.Library.columnGap
            )],
            alignment: .leading,
            spacing: ShellLayout.Library.rowGap
        ) {
            ForEach(Array(games.enumerated()), id: \.element.id) { offset, game in
                LibraryCard(game: game, badge: badge(game), now: now) { open(game) }
                    .riseIn(delay: Double(min(offset, ShellLayout.Library.maximumStaggeredCards))
                        * ShellLayout.Library.stagger)
                    .id("\(game.id)-\(viewModel.sort.rawValue)")
                    .contextMenu { contextMenu(for: game) }
            }
        }
    }

    private var filterChip: some View {
        Button(action: viewModel.clearFilters) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Text("Showing \(viewModel.filterDescription)")
                Image(systemName: "xmark")
            }
        }
        .buttonStyle(SurfacePillButtonStyle(isCompact: true))
        .accessibilityLabel("Showing \(viewModel.filterDescription). Show everything")
    }

    @ViewBuilder
    private func contextMenu(for game: Game) -> some View {
        Button("Play", systemImage: "play.fill") { play(game) }
        Divider()
        Menu("Set Status") {
            ForEach(GameStatus.allCases) { status in
                Button(status.displayName) { viewModel.setStatus(status, for: game) }
            }
        }
        Divider()
        Button("Remove from Library", role: .destructive) { viewModel.delete(game) }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    LibraryScreen(
        viewModel: environment.makeLibraryViewModel(),
        badge: { _ in nil },
        open: { _ in },
        play: { _ in },
        addGame: {}
    )
    .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
