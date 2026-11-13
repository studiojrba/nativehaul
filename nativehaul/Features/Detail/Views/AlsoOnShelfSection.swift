import SwiftUI

/// "Also on your shelf" (spec §3.3): up to three of the user's own games, three across; each opens its Detail.
struct AlsoOnShelfSection: View {
    /// The games.
    let games: [Game]
    /// Opens a game's Detail.
    let open: (Game) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.Detail.sectionContentTop) {
            Eyebrow("Also on your shelf")
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: ShellLayout.Detail.gridGap, alignment: .top),
                    count: ShellLayout.Detail.relatedCount
                ),
                alignment: .leading,
                spacing: ShellLayout.Detail.gridGap
            ) {
                ForEach(games, id: \.id) { game in
                    AlsoOnShelfCard(game: game) { open(game) }
                }
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let games = (try? environment.repository.fetchGames()) ?? []
    AppearancePreviewPair {
        AlsoOnShelfSection(games: Array(games.prefix(ShellLayout.Detail.relatedCount))) { _ in }
            .frame(width: ShellLayout.Detail.descriptionMaxWidth)
            .padding(DesignTokens.Spacing.xl)
    }
}
