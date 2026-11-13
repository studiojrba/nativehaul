import SwiftUI

/// Detail inside the shell (spec §3.3): builds the game's ``DetailViewModel`` once per game (the shell gives each game
/// its own page) and hands ``DetailScreen`` the shell's navigation and launch.
struct DetailPage: View {
    @State private var viewModel: DetailViewModel
    /// Goes back to where Detail was opened from.
    let back: () -> Void
    /// Plays the game through the shell (launch overlay, errors), by a route or the default.
    let play: (LaunchOption?) -> Void
    /// Opens another game's Detail.
    let open: (UUID) -> Void
    /// Opens Builds focused on this game.
    let openBuilds: () -> Void

    /// Creates the page. `library` lists the shelf ("Also on your shelf"); `badge` reports a game's real build badge.
    init(
        environment: AppEnvironment,
        game: Game,
        library: @escaping @MainActor () -> [Game],
        badge: @escaping @MainActor (Game) -> LibraryBuildBadge?,
        back: @escaping () -> Void,
        play: @escaping (LaunchOption?) -> Void,
        open: @escaping (UUID) -> Void,
        openBuilds: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: environment.makeDetailViewModel(
            for: game,
            buildBadge: { badge(game) },
            library: library
        ))
        self.back = back
        self.play = play
        self.open = open
        self.openBuilds = openBuilds
    }

    var body: some View {
        DetailScreen(
            viewModel: viewModel,
            back: back,
            play: play,
            open: { open($0.id) },
            openBuilds: openBuilds
        )
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let games = (try? environment.repository.fetchGames()) ?? []
    if let game = games.first {
        DetailPage(
            environment: environment,
            game: game,
            library: { games },
            badge: { _ in nil },
            back: {},
            play: { _ in },
            open: { _ in },
            openBuilds: {}
        )
        .environment(environment)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
    }
}
