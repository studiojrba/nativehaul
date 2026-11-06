import SwiftData
import SwiftUI

/// Adaptive cover grid for the selected library section.
struct LibraryGridView: View {
    /// Shared library state.
    @Bindable var viewModel: LibraryViewModel

    private let columns = [
        GridItem(
            .adaptive(minimum: DesignTokens.Cover.minWidth, maximum: DesignTokens.Cover.maxWidth),
            spacing: DesignTokens.Spacing.lg
        ),
    ]

    var body: some View {
        Group {
            if viewModel.visibleGames.isEmpty {
                ContentUnavailableView(
                    "No Games",
                    systemImage: viewModel.filter.section.symbolName,
                    description: Text("Add a game, import a library file, or sync Steam.")
                )
            } else {
                grid
            }
        }
        .navigationTitle(viewModel.filter.section.title)
        .searchable(text: $viewModel.filter.searchText, prompt: "Search titles")
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                ForEach(viewModel.visibleGames) { game in
                    NavigationLink(value: game.id) {
                        GameGridItem(game: game)
                    }
                    .buttonStyle(.plain)
                    .contextMenu { contextMenu(for: game) }
                }
            }
            .padding(DesignTokens.Spacing.xl)
        }
    }

    @ViewBuilder
    private func contextMenu(for game: Game) -> some View {
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
    NavigationStack {
        LibraryGridView(viewModel: environment.makeLibraryViewModel())
    }
    .modelContainer(environment.container)
}
