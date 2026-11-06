import SwiftUI

/// Left column of the details screen: the current library list for jumping between games.
struct GameQuickList: View {
    /// Games in the current section/search.
    let games: [Game]
    /// Game being shown.
    let selectedID: UUID
    /// Called with the chosen game's id.
    let onSelect: (UUID) -> Void

    var body: some View {
        List(games, selection: Binding(get: { selectedID }, set: { $0.map(onSelect) })) { game in
            Text(game.title)
                .lineLimit(DesignTokens.Lines.single)
                .tag(game.id)
        }
        .listStyle(.sidebar)
        .frame(width: DesignTokens.Details.quickListWidth)
    }
}

#Preview {
    let games = [Game(title: "Tideborn"), Game(title: "Moonwell")]
    GameQuickList(games: games, selectedID: games[0].id) { _ in }
        .frame(height: DesignTokens.Layout.windowMinHeight)
}
