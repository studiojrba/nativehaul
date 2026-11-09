import SwiftData
import SwiftUI

/// Adaptive cover grid for the selected library section.
struct LibraryGridView: View {
    /// Shared library state.
    @Bindable var viewModel: LibraryViewModel
    @Environment(AppEnvironment.self) private var environment
    @State private var isShowingUnknown = false

    private let columns = [
        GridItem(
            .adaptive(minimum: DesignTokens.Cover.minWidth, maximum: DesignTokens.Cover.maxWidth),
            spacing: DesignTokens.Spacing.xl
        ),
    ]

    var body: some View {
        let split = viewModel.filter.installedOnly ? viewModel.installedSplit : nil
        Group {
            if let split, split.installed.isEmpty, split.unknown.isEmpty {
                EmptyStateView(
                    title: "No installed games here",
                    symbolName: "internaldrive",
                    message: split.summary
                ) {
                    Button("Show All Games") { viewModel.filter.installedOnly = false }
                }
            } else if split == nil, viewModel.visibleGames.isEmpty {
                EmptyStateView(
                    title: "No games here yet",
                    symbolName: viewModel.filter.section.symbolName,
                    message: "Add a game, import a library file, or sync Steam."
                )
            } else {
                grid(split: split)
            }
        }
        .navigationTitle(viewModel.filter.section.title)
        .navigationSubtitle(split?.summary ?? "")
        .searchable(text: $viewModel.filter.searchText, prompt: "Search titles")
        .toolbar {
            ToolbarItem {
                Toggle("Installed", systemImage: "internaldrive", isOn: $viewModel.filter.installedOnly)
                    .toggleStyle(.button)
                    .help("Show only games with a present, launchable install")
            }
        }
    }

    private func grid(split: InstalledSplit?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxl) {
                JumpBackInShelf(games: viewModel.jumpBackIn())
                if let split {
                    Text(split.summary)
                        .font(DesignTokens.Typography.monospaced)
                        .foregroundStyle(Theme.secondaryText)
                }
                gameGrid(viewModel.visibleGames)
                if let split, !split.unknown.isEmpty {
                    UnknownInstallHeader(count: split.unknown.count, isShowing: $isShowingUnknown)
                    if isShowingUnknown {
                        gameGrid(split.unknown)
                    }
                }
            }
            .padding(DesignTokens.Spacing.xl)
        }
        .canvasBackground()
    }

    private func gameGrid(_ games: [Game]) -> some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: DesignTokens.Spacing.xxl) {
            ForEach(games) { game in
                NavigationLink(value: game.id) {
                    GameGridItem(game: game)
                }
                .buttonStyle(.plain)
                .contextMenu { contextMenu(for: game) }
            }
        }
    }

    @ViewBuilder
    private func contextMenu(for game: Game) -> some View {
        let launch = environment.makeGameLaunchViewModel(for: game)
        if launch.availability.options.isEmpty {
            Button("Play", systemImage: "play.slash") {}.disabled(true)
        }
        ForEach(launch.availability.options) { option in
            Button(option.title == "Play" ? "Play" : "Play via \(option.title)", systemImage: "play.fill") {
                Task { await launch.launch(option) }
            }
        }
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
    NavigationStack {
        LibraryGridView(viewModel: environment.makeLibraryViewModel())
    }
    .modelContainer(environment.container)
    .environment(environment)
}
