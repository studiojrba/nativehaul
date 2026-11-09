import SwiftUI

/// Meebits' pale graph-paper grid (ADR 0037, item 3): the canvas colour with very faint lines, for library surfaces.
/// Drawn once per size with `Canvas`, so it costs nothing per card.
struct GraphPaperBackground: View {
    @Environment(\.designIntensity) private var intensity

    var body: some View {
        let level = EnergyLevel.of(intensity)
        Canvas { context, size in
            var path = Path()
            for x in stride(from: 0, through: size.width, by: level.gridSpacing) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: level.gridSpacing) {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(
                path,
                with: .color(Theme.primaryText.opacity(level.gridLineOpacity)),
                lineWidth: DesignTokens.Stroke.hairline
            )
        }
        .background(Theme.canvas)
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    GraphPaperBackground()
        .frame(width: DesignTokens.Layout.detailMinWidth, height: DesignTokens.Layout.logMinHeight)
}
