import SwiftUI

/// One game tile (ADR 0052). Focus never draws a border on the art: the focused tile grows ~9%, lifts on a soft
/// shadow and shows its title underneath; the others dim. (The plan's accent-coloured title waits on J.R: the
/// accent stays on Play, nav and links, EnergyPassTests.) Reduce Motion turns the animation off.
struct TVTileView: View {
    /// The game.
    let game: Game
    /// Whether it has the focus.
    let isFocused: Bool
    /// Its height.
    let height: CGFloat
    /// Screen metrics.
    let metrics: TVMetrics
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: metrics.halfGap) {
            CoverArtView(imagePath: game.coverImagePath ?? game.heroImagePath, title: game.title)
                .frame(height: height)
                .clipShape(RoundedRectangle(cornerRadius: metrics.tileRadius))
                .scaleEffect(isFocused ? DesignTokens.TVMode.focusScale : 1)
                .shadow(
                    color: Theme.artworkScrim.opacity(isFocused ? DesignTokens.TVMode.focusShadowOpacity : 0),
                    radius: metrics.focusShadowRadius,
                    y: metrics.focusLift
                )
                .offset(y: isFocused ? -metrics.focusLift : 0)
            Text(game.title)
                .font(metrics.bodyEmphasisFont)
                .lineLimit(DesignTokens.Lines.single)
                .foregroundStyle(Theme.primaryText)
                .opacity(isFocused ? 1 : 0)
        }
        .frame(width: height * DesignTokens.Cover.widthToHeight)
        .opacity(isFocused ? 1 : DesignTokens.TVMode.unfocusedOpacity)
        .animation(reduceMotion ? nil : .easeOut(duration: DesignTokens.TVMode.focusAnimation), value: isFocused)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isFocused ? .isSelected : [])
    }
}

#Preview {
    let metrics = TVMetrics(size: DesignTokens.TVMode.previewScreen)
    HStack(spacing: metrics.gap) {
        TVTileView(game: Game(title: "Tideborn"), isFocused: true, height: metrics.tileHeight(.shelf), metrics: metrics)
        TVTileView(
            game: Game(title: "Moonwell"),
            isFocused: false,
            height: metrics.tileHeight(.shelf),
            metrics: metrics
        )
    }
    .padding(DesignTokens.Spacing.xxl)
    .background(Theme.canvas)
}
