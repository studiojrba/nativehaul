import SwiftUI

/// The search dropdown (spec §3.0): frosted, radius 24, padding 8, `elev-lg`, rising in; up to five results or, with
/// none, "Nothing called “{query}” on the shelf. Yet."
struct SearchResultsPanel: View {
    /// What was typed.
    let query: String
    /// The matches.
    let results: [Game]
    /// Opens a result.
    let select: (Game) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if results.isEmpty {
                Text("Nothing called “\(query)” on the shelf. Yet.")
                    .font(Typeface.sans(TypeStyle.Size.body))
                    .foregroundStyle(Theme.inkSoft)
                    .padding(.horizontal, ShellLayout.Chrome.emptyHorizontal)
                    .padding(.vertical, ShellLayout.Chrome.emptyVertical)
            } else {
                ForEach(results) { game in
                    SearchResultRow(game: game) { select(game) }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ShellLayout.TopBar.resultsPadding)
        .frostedGlass(in: RoundedRectangle(cornerRadius: ShellLayout.TopBar.resultsRadius, style: .continuous))
        .elevation(.large)
        .riseIn()
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SearchResultsPanel(query: "lan", results: [Game(title: "Lantern Coast")]) { _ in }
            SearchResultsPanel(query: "zzz", results: []) { _ in }
        }
        .frame(width: ShellLayout.TopBar.searchMaxWidth)
        .padding(DesignTokens.Spacing.xl)
    }
}
