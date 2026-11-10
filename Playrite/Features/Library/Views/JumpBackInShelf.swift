import SwiftUI

/// "Jump Back In": a single row of recent games above the All Games grid. Renders nothing when empty.
struct JumpBackInShelf: View {
    /// Shelf games, most recent first.
    let games: [Game]
    /// Reference time for the "last played" line.
    var now: Date = .now

    var body: some View {
        if !games.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                SectionHeader(
                    title: "Jump Back In",
                    caption: "playing, or unfinished and played in the last 30 days",
                    style: .shelf
                )
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: DesignTokens.Spacing.xl) {
                        ForEach(games) { game in
                            NavigationLink(value: game.id) {
                                CoverCard(
                                    title: game.title,
                                    subtitle: JumpBackIn.lastPlayed(for: game, now: now),
                                    imagePath: game.coverImagePath
                                ) {
                                    if let played = JumpBackIn.timePlayed(for: game) {
                                        Text(played)
                                            .font(DesignTokens.Typography.figuresSmall)
                                            .foregroundStyle(Theme.secondaryText)
                                            .lineLimit(DesignTokens.Lines.single)
                                    }
                                }
                                .frame(width: DesignTokens.Cover.minWidth)
                                .accessibilityLabel("\(game.title), \(JumpBackIn.line(for: game, now: now))")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                HairlineDivider()
            }
        }
    }
}

#Preview {
    let playing = Game(title: "Tideborn", status: .playing)
    NavigationStack {
        JumpBackInShelf(games: [playing])
            .padding(DesignTokens.Spacing.xl)
    }
}
