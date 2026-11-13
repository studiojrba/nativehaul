import SwiftUI

/// A couch tile (spec §3.7): the cover at 3:4 with a 28pt radius. Focused, it scales to 1.14 from its bottom centre,
/// rises above its neighbours and wears a 5pt accent ring 6pt out (the gap in `paper`) with the couch-focus shadow
/// (an ember glow at night). Transitions 500ms ease-settle.
struct CouchTile: View {
    /// The game.
    let game: Game
    /// Whether the tile has focus.
    let isFocused: Bool
    /// The couch scale.
    let scale: CouchScale

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = CouchLayout.Tile

    var body: some View {
        let width = scale(CouchLayout.Shelves.tileWidth)
        let shape = RoundedRectangle(cornerRadius: scale(Metrics.radius), style: .continuous)
        ArtworkFill(path: game.coverImagePath, title: game.title, placeholderSize: scale(Metrics.title))
            .frame(width: width, height: width / Metrics.aspect)
            .clipShape(shape)
            .couchFocusRing(isFocused, in: shape, width: scale(Metrics.ringWidth), offset: scale(Metrics.ringOffset))
            .shadow(isFocused ? CouchFocusTokens.tile(colorScheme) : Elevation.regular.shadows(for: colorScheme))
            .scaleEffect(isFocused ? Metrics.focusScale : 1, anchor: .bottom)
            .zIndex(isFocused ? 1 : 0)
            .animation(reduceMotion ? nil : Motion.settle(), value: isFocused)
            .accessibilityElement()
            .accessibilityLabel(game.title)
            .accessibilityAddTraits(isFocused ? .isSelected : [])
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        HStack(spacing: scale(CouchLayout.Shelves.tileGap)) {
            CouchTile(game: Game(title: "Lantern Coast"), isFocused: true, scale: scale)
            CouchTile(game: Game(title: "Tideborn"), isFocused: false, scale: scale)
        }
        .padding(KitMetrics.Spacing.page)
    }
}
