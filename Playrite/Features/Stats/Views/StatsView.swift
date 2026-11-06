import SwiftUI

/// Stats sidebar screen.
struct StatsView: View {
    @State private var viewModel: StatsViewModel

    private let tileColumns = [GridItem(
        .adaptive(minimum: DesignTokens.Layout.statTileMinWidth),
        spacing: DesignTokens.Spacing.md
    )]

    /// Creates the view.
    init(viewModel: StatsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxl) {
                SectionHeader(title: "Library")
                LazyVGrid(columns: tileColumns, alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    StatTile(title: "Games", value: "\(viewModel.stats.totalGames)", symbolName: "square.grid.2x2")
                    ForEach(GameStatus.allCases) { status in
                        StatTile(
                            title: status.displayName,
                            value: "\(viewModel.stats.count(status))",
                            symbolName: status.symbolName
                        )
                    }
                    StatTile(title: "Completion", value: viewModel.completionText, symbolName: "percent")
                }
                HoursBySourceView(entries: viewModel.hoursBySource)
                SectionHeader(
                    title: "Badges",
                    caption: "\(viewModel.earnedCount) of \(viewModel.badges.count) earned · real data only"
                )
                LazyVGrid(columns: tileColumns, alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    ForEach(viewModel.badges) { BadgeTile(result: $0) }
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Theme.danger)
                }
            }
            .padding(DesignTokens.Spacing.xl)
        }
        .navigationTitle("Stats")
        .onAppear { viewModel.reload() }
    }
}

#Preview {
    StatsView(viewModel: AppEnvironment.preview.makeStatsViewModel())
}
