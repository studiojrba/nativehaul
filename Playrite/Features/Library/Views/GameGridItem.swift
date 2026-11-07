import SwiftUI

/// One poster in the library grid: the title and one quiet line — hours played, or the status (ADR 0025).
struct GameGridItem: View {
    /// Game to render.
    let game: Game

    var body: some View {
        CoverCard(title: game.title, subtitle: GameInfoBuilder.cardLine(for: game), imagePath: game.coverImagePath)
    }
}

#Preview {
    GameGridItem(game: Game(title: "Tideborn", platform: .switchPort))
        .frame(width: DesignTokens.Cover.minWidth)
        .padding(DesignTokens.Spacing.lg)
}
