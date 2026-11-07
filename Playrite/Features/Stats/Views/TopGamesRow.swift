import SwiftUI

/// The story that leads the Stats page (ADR 0025): your most-played games, ranked, with their art. The rank numbers
/// are the page's one accent pop.
struct TopGamesRow: View {
    /// Ranked games.
    let games: [RankedGame]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader(title: "Most played", caption: "largest real figure per game · never merged", style: .display)
            if games.isEmpty {
                Text("Play something and your top games show up here.")
                    .foregroundStyle(Theme.secondaryText)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.xl) {
                        ForEach(games) { game in
                            entry(game)
                        }
                    }
                }
            }
        }
    }

    private func entry(_ game: RankedGame) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            ZStack(alignment: .bottomLeading) {
                CoverArtView(imagePath: game.coverImagePath, title: game.title, width: DesignTokens.Cover.minWidth)
                    .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.md).strokeBorder(Theme.hairline))
                Text("\(game.rank)")
                    .font(DesignTokens.Typography.rank)
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .background(
                        UnevenRoundedRectangle(topTrailingRadius: DesignTokens.Radius.md)
                            .fill(Theme.canvas)
                    )
            }
            Text(game.title)
                .font(DesignTokens.Typography.headline)
                .lineLimit(DesignTokens.Lines.single)
            Text(game.playtimeText)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(DesignTokens.Lines.single)
        }
        .frame(width: DesignTokens.Cover.minWidth, alignment: .leading)
    }
}

#Preview {
    TopGamesRow(games: [
        RankedGame(id: UUID(), rank: 1, title: "Tideborn", coverImagePath: nil, seconds: 240_120, source: .steamSynced),
        RankedGame(id: UUID(), rank: 2, title: "Ridgeback", coverImagePath: nil, seconds: 36000, source: .macTracked),
    ])
    .padding(DesignTokens.Spacing.xl)
    .background(Theme.canvas)
}
