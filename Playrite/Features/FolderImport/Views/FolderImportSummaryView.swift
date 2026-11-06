import SwiftUI

/// Read-only breakdown of a ``FolderImportSummary``, with CrossOver reported separately.
struct FolderImportSummaryView: View {
    /// Summary to show.
    let summary: FolderImportSummary

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            SectionHeader(title: "Last Scan")
            LabeledValueRow(label: "Found") { Text("\(summary.found)") }
            LabeledValueRow(label: "Added") { Text("\(summary.added)") }
            LabeledValueRow(label: "Linked") { Text("\(summary.linked)") }
            LabeledValueRow(label: "Skipped") { Text("\(summary.skipped)") }
            LabeledValueRow(label: "CrossOver bottles found") { Text("\(summary.bottlesFound)") }
            LabeledValueRow(label: "CrossOver games added") { Text("\(summary.crossOverAdded)") }
            if let steam = summary.steam {
                LabeledValueRow(label: "Steam installs (Mac)") { Text("\(steam.macInstalls)") }
                LabeledValueRow(label: "Steam installs (CrossOver)") { Text("\(steam.crossOverInstalls)") }
                LabeledValueRow(label: "Steam games linked / added") { Text("\(steam.linked) / \(steam.added)") }
            }
            if summary.duplicatesMerged > 0 {
                LabeledValueRow(label: "Duplicates merged") { Text("\(summary.duplicatesMerged)") }
            }
            ForEach(summary.unreadableFolders, id: \.self) { folder in
                Label("Could not read \(folder)", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(Theme.warning)
            }
        }
        .font(DesignTokens.Typography.body)
    }
}

#Preview {
    FolderImportSummaryView(summary: FolderImportSummary(
        found: 6, added: 3, linked: 2, skipped: 1, bottlesFound: 1, crossOverAdded: 2,
        unreadableFolders: ["/Volumes/External/Games"]
    ))
    .padding(DesignTokens.Spacing.lg)
}
