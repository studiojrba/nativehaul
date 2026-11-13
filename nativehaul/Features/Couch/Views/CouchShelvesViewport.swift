import SwiftUI

/// The shelves viewport (spec §3.7): from `48vh − 24` to the bottom, full width, clipped with soft fades — never hard
/// edges. Rows are 400pt; moving down shifts the stack by a row (700ms ease-settle); the focused row is opaque, rows
/// below 45%, rows above hidden.
struct CouchShelvesViewport: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = CouchLayout.Shelves

    var body: some View {
        let scale = viewModel.scale
        let top = scale.height(Metrics.topShare) - scale(Metrics.topLift)
        let height = max(0, scale.size.height - top)
        let row = viewModel.state.home.row
        let shelves = viewModel.shelves
        VStack(spacing: 0) {
            ForEach(Array(shelves.enumerated()), id: \.element.id) { index, shelf in
                CouchShelfRow(
                    shelf: shelf,
                    games: shelf.items.compactMap { viewModel.library.game(withID: $0.id) },
                    focusColumn: index == row ? viewModel.state.home.columns[safe: index] : nil,
                    start: start(of: index, shelf: shelf),
                    visibleCount: scale.visibleTiles,
                    scale: scale
                )
                .frame(height: scale(Metrics.rowHeight), alignment: .top)
                .opacity(opacity(index: index, row: row))
            }
        }
        .padding(.top, scale(Metrics.topFade))
        .offset(y: -CGFloat(max(0, row)) * scale(Metrics.rowHeight))
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.rise), value: row)
        .frame(width: scale.size.width, height: height, alignment: .top)
        .clipped()
        .mask { fade(height: height, scale: scale) }
        .padding(.top, top)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func start(of index: Int, shelf: CouchShelf) -> Int {
        let stored = viewModel.state.home.starts[safe: index] ?? 0
        return min(stored, max(0, shelf.items.count - viewModel.scale.visibleTiles))
    }

    private func opacity(index: Int, row: Int) -> Double {
        if index == row {
            return 1
        }
        return index < row ? 0 : Metrics.belowOpacity
    }

    private func fade(height: CGFloat, scale: CouchScale) -> some View {
        let length = max(1, height)
        return LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: min(1, scale(Metrics.topFade) / length)),
                .init(color: .black, location: max(0, (length - scale(Metrics.bottomFadeStart)) / length)),
                .init(color: .clear, location: max(0, (length - scale(Metrics.bottomFadeEnd)) / length)),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    CouchShelvesViewport(viewModel: .preview)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
