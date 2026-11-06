import SwiftUI

/// One game cell in the library grid.
struct GameGridItem: View {
    /// Game to render.
    let game: Game

    var body: some View {
        CoverCard(title: game.title, subtitle: game.platform.displayName, imagePath: game.coverImagePath) {
            StatusTag(status: game.status)
        }
    }
}

#Preview {
    GameGridItem(game: Game(title: "Tideborn", platform: .switchPort))
        .frame(width: DesignTokens.Cover.minWidth)
        .padding(DesignTokens.Spacing.lg)
}
