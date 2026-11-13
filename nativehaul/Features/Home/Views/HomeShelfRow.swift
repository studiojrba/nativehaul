import SwiftUI

/// A curated shelf on Home (note 14; Make `Row`): a rounded wash panel whose heading lines up with the page column,
/// over a shelf of covers that scroll right up to the panel's edges.
struct HomeShelfRow: View {
    /// The shelf.
    let shelf: HomeShelf
    /// Opens a game's Detail.
    let open: (Game) -> Void

    @State private var panelWidth: CGFloat = 0

    private typealias Metrics = ShellLayout.HomeShelves

    var body: some View {
        let inset = Metrics.inset(panelWidth: panelWidth)
        VStack(alignment: .leading, spacing: Metrics.cardsTop) {
            SectionHead(eyebrow: shelf.kind.eyebrow, title: shelf.kind.title)
                .padding(.horizontal, inset)
            ShelfScroller(leadingInset: inset, trailingInset: inset, gap: Metrics.gap) {
                ForEach(shelf.games, id: \.id) { game in
                    HomeShelfCard(game: game, badge: shelf.badge(for: game)) { open(game) }
                }
            }
        }
        .padding(.vertical, Metrics.panelVertical)
        .background {
            RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous)
                .fill(Theme.wash(shelf.kind.wash).opacity(Metrics.washOpacity))
        }
        .clipShape(RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous))
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { panelWidth = $0 }
        .padding(.leading, Metrics.panelLeading)
        .padding(.trailing, Metrics.panelTrailing)
        .padding(.top, Metrics.panelTop)
    }
}

#Preview {
    let games = ["Lantern Coast", "Tideborn", "Moss & Ember", "Velvet Orbit"].map { Game(title: $0) }
    AppearancePreviewPair {
        HomeShelfRow(shelf: HomeShelf(kind: .notStarted, games: games)) { _ in }
    }
}
