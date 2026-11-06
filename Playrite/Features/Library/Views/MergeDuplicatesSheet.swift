import SwiftUI

/// Preview-then-confirm sheet for merging same-titled library entries.
struct MergeDuplicatesSheet: View {
    @State private var viewModel: MergeDuplicatesViewModel
    @Environment(\.dismiss) private var dismiss

    /// Creates the sheet.
    init(viewModel: MergeDuplicatesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Merge Duplicate Games", caption: "same title → one entry")
            content
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(Theme.danger)
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth, minHeight: DesignTokens.Layout.logMinHeight)
        .task { viewModel.refresh() }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Merge \(viewModel.pendingDeletions) Duplicates") { viewModel.mergeAll() }
                    .disabled(viewModel.groups.isEmpty)
            }
        }
    }

    @ViewBuilder private var content: some View {
        if let deleted = viewModel.deletedCount {
            ContentUnavailableView(
                "Merged",
                systemImage: "checkmark.circle",
                description: Text("\(deleted) duplicate entries were merged and removed.")
            )
        } else if viewModel.groups.isEmpty {
            ContentUnavailableView("No Duplicates", systemImage: "square.on.square")
        } else {
            Text(
                "Each entry keeps its imported data (status, hours, description, series, guides, HLTB) and gains "
                    + "the duplicate's tracked app, sessions and Steam data. The duplicate is then deleted."
            )
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(Theme.secondaryText)
            List(viewModel.groups) { DuplicateGroupRow(group: $0) }
        }
    }
}

#Preview {
    MergeDuplicatesSheet(viewModel: MergeDuplicatesViewModel(deduplicator: MockLibraryDeduplicator()))
}
