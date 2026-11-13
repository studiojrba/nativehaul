import SwiftUI

/// One couch Home shelf (spec §3.7): its title at the gutter, then the tiles from the gutter, shifted so the first
/// visible tile sits at the gutter (700ms ease-settle). Paging arrows sit level with the tiles 4pt from the edges and
/// hide at the shelf's ends (shelves don't wrap); couch focus scales them up with an ember glow.
struct CouchShelfRow: View {
    /// The shelf.
    let shelf: CouchShelf
    /// Its games, in order.
    let games: [Game]
    /// The focused column (`nil` when another row has focus; −1 / count are the arrows).
    let focusColumn: Int?
    /// The first visible tile.
    let start: Int
    /// Tiles fully visible.
    let visibleCount: Int
    /// The couch scale.
    let scale: CouchScale

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = CouchLayout.Shelves

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                Text(shelf.title)
                    .font(Typeface.sans(scale(Metrics.title), weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .padding(.leading, scale(CouchLayout.gutter))
                tiles
                    .padding(.top, scale(Metrics.tilesTop))
            }
            arrows
        }
        .frame(width: scale.size.width, alignment: .topLeading)
    }

    private var tiles: some View {
        HStack(spacing: scale(Metrics.tileGap)) {
            ForEach(Array(games.enumerated()), id: \.element.id) { offset, game in
                CouchTile(game: game, isFocused: focusColumn == offset, scale: scale)
            }
        }
        .padding(.horizontal, scale(CouchLayout.gutter))
        .padding(.vertical, scale(Metrics.tilesVertical))
        .fixedSize()
        .offset(x: -CGFloat(start) * scale(Metrics.tileWidth + Metrics.tileGap))
        .frame(width: scale.size.width, alignment: .leading)
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.rise), value: start)
    }

    private var arrows: some View {
        HStack {
            ChevronButton(
                direction: .leading,
                size: scale(Metrics.arrowSize),
                isVisible: start > 0,
                isFocused: focusColumn == CouchHomeFocus.leftArrowColumn
            ) {}
            Spacer(minLength: 0)
            ChevronButton(
                direction: .trailing,
                size: scale(Metrics.arrowSize),
                isVisible: start + visibleCount < games.count,
                isFocused: focusColumn == games.count
            ) {}
        }
        .padding(.horizontal, scale(CouchLayout.Hero.arrowInset))
        .frame(height: scale(Metrics.arrowBand), alignment: .center)
        .allowsHitTesting(false)
    }
}

#Preview {
    let games = ["Astral Chain", "Bayonetta", "Celeste", "Dredge", "Eastward", "Fez", "Gris"].map { Game(title: $0) }
    let shelf = CouchShelf(title: "Everything, A–Z", items: games.map(CouchShelves.item))
    let scale = CouchScale(size: CouchLayout.previewScreen)
    AppearancePreviewPair {
        CouchShelfRow(shelf: shelf, games: games, focusColumn: 2, start: 1, visibleCount: 6, scale: scale)
            .frame(height: scale(CouchLayout.Shelves.rowHeight))
    }
}
