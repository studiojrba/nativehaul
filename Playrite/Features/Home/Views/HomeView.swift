import SwiftUI

/// Home, the landing page (ADR 0035): the hero of installed games with banner art, then Jump Back In, then Recently
/// Added. Every part hides when it has nothing; an empty library offers Add Game, and a library with nothing for Home
/// yet offers a way to All Games, so Home is never a dead end (ADR 0025 item 7).
struct HomeView: View {
    /// The shared library state.
    let libraryViewModel: LibraryViewModel
    /// Makes a game's Play button view model.
    let makeLaunch: (Game) -> GameLaunchViewModel
    /// Opens Add Game.
    let onAddGame: () -> Void
    /// Goes to All Games.
    let onBrowseLibrary: () -> Void
    /// Reference time.
    var now: Date = .now
    /// File check, injectable for previews and tests.
    var fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    @State private var carousel = HeroCarousel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let feed = HomeFeed.make(from: libraryViewModel.games, now: now, fileExists: fileExists)
        Group {
            if libraryViewModel.games.isEmpty {
                EmptyStateView(
                    title: "Your library is empty",
                    symbolName: "house",
                    message: "Add a game, or let NX Shelf find the ones already on your Mac."
                ) {
                    Button("Add Game", systemImage: "plus", action: onAddGame)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignTokens.Home.sectionSpacing) {
                        HomeHero(heroes: feed.heroes, carousel: carousel, makeLaunch: makeLaunch, now: now)
                        JumpBackInShelf(games: feed.jumpBackIn, now: now)
                        RecentlyAddedShelf(games: feed.recentlyAdded, now: now)
                        Button("Browse All Games", systemImage: "square.grid.2x2", action: onBrowseLibrary)
                            .buttonStyle(.borderless)
                    }
                    .padding(DesignTokens.Spacing.xl)
                }
            }
        }
        .background {
            HomeAmbientBackground(imagePath: featuredImage(in: feed))
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: DesignTokens.Home.crossfadeSeconds),
                    value: featuredImage(in: feed)
                )
        }
        .scrollContentBackground(.hidden)
    }

    private func featuredImage(in feed: HomeFeed) -> String? {
        feed.heroes.isEmpty ? nil : feed.heroes[min(carousel.index, feed.heroes.count - 1)].heroImagePath
    }
}

#Preview {
    let environment = AppEnvironment.preview
    NavigationStack {
        HomeView(
            libraryViewModel: environment.makeLibraryViewModel(),
            makeLaunch: environment.makeGameLaunchViewModel(for:),
            onAddGame: {},
            onBrowseLibrary: {}
        )
    }
}
