import SwiftUI

/// Detail-screen block for HowLongToBeat estimates. Every figure is labelled "HLTB estimate".
struct HLTBSection: View {
    @State private var viewModel: HLTBViewModel
    @State private var isEditing = false

    /// Creates the section.
    init(viewModel: HLTBViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "How Long to Beat", caption: "community estimates — not playtime")
            if let problem = viewModel.loadProblem {
                Text(problem).foregroundStyle(Theme.danger).fixedSize(horizontal: false, vertical: true)
            }
            if viewModel.rows.isEmpty {
                Text("No estimate cached.").foregroundStyle(Theme.secondaryText)
            }
            ForEach(viewModel.rows, id: \.category) { row in
                LabeledValueRow(label: row.category.displayName) {
                    Text(row.text).font(DesignTokens.Typography.monospaced)
                }
            }
            if let estimate = viewModel.estimate {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text("Recorded \(estimate.recordedAt.formatted(date: .abbreviated, time: .omitted))")
                    if viewModel.isStale {
                        TagLabel(
                            text: "Stale",
                            symbolName: "clock.arrow.circlepath",
                            tint: Theme.warning
                        )
                    }
                }
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
            }
            if let note = viewModel.note {
                Text(note).font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
            }
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(Theme.danger)
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Look Up on HowLongToBeat", systemImage: "arrow.up.right.square") { viewModel.openSearch() }
                Button("Enter Estimates…") { isEditing = true }
            }
            Text(
                "Source: HowLongToBeat.com. NX Shelf does not scrape HowLongToBeat; "
                    + "figures are entered by you and cached locally."
            )
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(Theme.secondaryText)
        }
        .task { await viewModel.refresh() }
        .sheet(isPresented: $isEditing) {
            HLTBEntrySheet(initial: viewModel.estimate) { viewModel.saveManual(hours: $0) }
        }
    }
}

#Preview {
    HLTBSection(viewModel: AppEnvironment.preview.makeHLTBViewModel(for: Game(title: "Tideborn")))
        .padding(DesignTokens.Spacing.lg)
}
