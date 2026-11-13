import SwiftUI

/// One item of couch's nav column (the nav island at 10-foot scale): icon and label; the current screen's icon in the
/// accent (as on the island), the focused item on `surface` with the accent ring.
struct CouchNavRow: View {
    /// SF Symbol.
    let symbol: String
    /// Label.
    let title: String
    /// Whether it is the screen on show.
    let isCurrent: Bool
    /// Whether it has focus.
    let isFocused: Bool
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.Nav

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: scale(Metrics.itemRadius), style: .continuous)
        HStack(spacing: scale(Metrics.itemGap)) {
            Image(systemName: symbol)
                .font(.system(size: scale(Metrics.icon)))
                .foregroundStyle(isCurrent ? Theme.accent : Theme.ink)
            Text(title)
                .font(Typeface.sans(scale(Metrics.label), weight: isCurrent ? .medium : .regular))
                .foregroundStyle(Theme.ink)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, scale(Metrics.itemPadding))
        .frame(height: scale(Metrics.itemHeight))
        .background { shape.fill(isFocused ? Theme.surface : .clear) }
        .couchFocusRing(isFocused, in: shape, width: scale(CouchLayout.Tile.ringWidth), offset: 0)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isFocused ? .isSelected : [])
    }
}

#Preview {
    let scale = CouchScale(size: CouchLayout.previewScreen)
    AppearancePreviewPair {
        VStack {
            CouchNavRow(symbol: "house", title: "Home", isCurrent: true, isFocused: false, scale: scale)
            CouchNavRow(symbol: "square.grid.2x2", title: "Library", isCurrent: false, isFocused: true, scale: scale)
        }
        .frame(width: scale(CouchLayout.Nav.width))
        .padding(KitMetrics.Spacing.page)
    }
}
