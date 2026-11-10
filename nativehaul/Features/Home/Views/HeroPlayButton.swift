import SwiftUI

/// The hero's big Play button: the standard ``LaunchButton`` for one game, its view model kept for the game's time
/// on screen.
struct HeroPlayButton: View {
    @State private var viewModel: GameLaunchViewModel

    /// Creates the button for `game`.
    init(game: Game, makeLaunch: (Game) -> GameLaunchViewModel) {
        _viewModel = State(initialValue: makeLaunch(game))
    }

    var body: some View {
        LaunchButton(viewModel: viewModel)
            .frame(width: DesignTokens.Home.playWidth)
    }
}

#Preview {
    HeroPlayButton(game: Game(title: "Tideborn")) { AppEnvironment.preview.makeGameLaunchViewModel(for: $0) }
        .padding(DesignTokens.Spacing.xl)
}
