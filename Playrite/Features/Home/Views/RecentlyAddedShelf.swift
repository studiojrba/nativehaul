import SwiftUI

/// "Recently Added" on Home: games added in the last 30 days, newest first. Renders nothing when empty.
struct RecentlyAddedShelf: View {
    /// Shelf games, newest first.
    let games: [Game]
    /// Reference time for the "added" line.
    var now: Date = .now

    var body: some View {
        if !games.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                SectionHeader(title: "Recently Added", caption: "added in the last 30 days")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: DesignTokens.Spacing.xl) {
                        ForEach(games) { game in
                            NavigationLink(value: game.id) {
                                CoverCard(title: game.title, subtitle: addedLine(game), imagePath: game.coverImagePath)
                                    .frame(width: DesignTokens.Cover.minWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func addedLine(_ game: Game) -> String {
        JumpBackIn.relativeDay(game.addedAt, now: now)
    }
}

#Preview {
    NavigationStack {
        RecentlyAddedShelf(games: [Game(title: "Tideborn")])
            .padding(DesignTokens.Spacing.xl)
    }
}
