import SwiftUI

/// Cover, title, metadata and status picker for the detail screen.
struct GameDetailHeader: View {
    /// Detail state.
    @Bindable var viewModel: GameDetailViewModel

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.xl) {
            CoverArtView(
                imagePath: viewModel.game.coverImagePath,
                title: viewModel.game.title,
                width: DesignTokens.Cover.detailWidth
            )
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(viewModel.game.title).font(DesignTokens.Typography.largeTitle)
                LabeledValueRow(label: "Platform") { Text(viewModel.game.platform.displayName) }
                LabeledValueRow(label: "Status") {
                    Picker("Status", selection: $viewModel.status) {
                        ForEach(GameStatus.allCases) { Text($0.displayName).tag($0) }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                if let releaseDate = viewModel.game.releaseDate {
                    LabeledValueRow(label: "Released") { Text(releaseDate, format: .dateTime.year()) }
                }
                LabeledValueRow(label: "Self-reported hours") {
                    TextField("Hours", value: $viewModel.selfReportedHours, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .fixedSize()
                    PlaytimeSourceTag(source: .selfReported)
                }
                if !viewModel.game.summary.isEmpty {
                    Text(viewModel.game.summary)
                        .lineLimit(DesignTokens.Lines.summary)
                        .foregroundStyle(Theme.secondaryText)
                }
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        GameDetailHeader(viewModel: GameDetailViewModel(game: game, repository: environment.repository))
            .padding(DesignTokens.Spacing.xl)
    }
}
