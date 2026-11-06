import SwiftUI

/// Full detail screen for one game. Feature sections are composed vertically.
struct GameDetailView: View {
    @State private var viewModel: GameDetailViewModel
    @Environment(AppEnvironment.self) private var environment

    /// Creates the screen for a game.
    init(viewModel: GameDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxl) {
                GameDetailHeader(viewModel: viewModel)
                PlaytimeBreakdownView(breakdown: viewModel.breakdown)
                SessionListView(sessions: viewModel.sessions)
                if viewModel.game.steamAppID != nil {
                    SteamAchievementsSection(viewModel: environment.makeSteamAchievementsViewModel(for: viewModel.game))
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundStyle(Theme.danger)
                }
            }
            .padding(DesignTokens.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(viewModel.game.title)
        .fileImporter(isPresented: $isPickingCover, allowedContentTypes: [.image]) { result in
            if case let .success(url) = result {
                viewModel.setCoverImagePath(url.path)
            }
        }
        .toolbar {
            Button("Choose Cover…", systemImage: "photo") { isPickingCover = true }
        }
    }

    @State private var isPickingCover = false
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        GameDetailView(viewModel: environment.makeGameDetailViewModel(for: game))
            .environment(environment)
    }
}
