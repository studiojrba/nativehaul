import SwiftUI

/// One poster in the library grid, keeping title, platform/playtime and status under the cover.
struct GameGridItem: View {
    /// Game to render.
    let game: Game

    var body: some View {
        CoverCard(title: game.title, subtitle: GameInfoBuilder.gridCaption(for: game), imagePath: game.coverImagePath) {
            StatusTag(status: game.status)
        }
    }
}

#Preview {
    GameGridItem(game: Game(title: "Tideborn", platform: .switchPort))
        .frame(width: DesignTokens.Cover.minWidth)
        .padding(DesignTokens.Spacing.lg)
}
