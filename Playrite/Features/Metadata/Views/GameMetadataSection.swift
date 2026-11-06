import SwiftUI

/// Manage sheet section: metadata sources per field and a Refresh Metadata button.
struct GameMetadataSection: View {
    @State private var viewModel: GameMetadataViewModel

    /// Creates the section.
    init(viewModel: GameMetadataViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Metadata")
            if viewModel.sourceRows.isEmpty {
                Text("No fetched metadata yet.").foregroundStyle(Theme.secondaryText)
            }
            ForEach(viewModel.sourceRows, id: \.field) { row in
                LabeledValueRow(label: row.field.displayName) {
                    Text(row.source.displayName).foregroundStyle(Theme.secondaryText)
                }
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Refresh Metadata", systemImage: "arrow.clockwise") {
                    Task { await viewModel.refresh() }
                }
                .disabled(viewModel.isRefreshing)
                if viewModel.isRefreshing {
                    ProgressView().controlSize(.small)
                }
            }
            Text("Refreshing never replaces art you chose yourself.")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
            if let message = viewModel.statusMessage {
                Text(message).foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

#Preview {
    GameMetadataSection(viewModel: GameMetadataViewModel(
        game: Game(title: "Skyward Lanterns"),
        fetcher: MockMetadataFetcher()
    ))
    .padding(DesignTokens.Spacing.lg)
}
