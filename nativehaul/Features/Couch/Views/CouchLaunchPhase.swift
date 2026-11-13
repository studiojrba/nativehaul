import SwiftUI

/// The couch launch phase (spec §3.7): full screen in the game's wash — the cover floating, "Here we go…" and
/// "Starting {short}" (the app that runs it is never named) — until the real handoff takes over. The game itself is
/// the playing screen.
struct CouchLaunchPhase: View {
    /// The game starting.
    let game: Game
    /// Its palette.
    let palette: GamePalette
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.Launch

    var body: some View {
        ZStack {
            CouchBackdrop(game: game, palette: palette)
            VStack(spacing: 0) {
                ArtworkFill(
                    path: game.coverImagePath,
                    title: game.title,
                    placeholderSize: scale(CouchLayout.Tile.title)
                )
                .frame(
                    width: scale(Metrics.coverWidth),
                    height: scale(Metrics.coverWidth) / CouchLayout.Tile.aspect
                )
                .clipShape(RoundedRectangle(cornerRadius: scale(Metrics.coverRadius), style: .continuous))
                .elevation(.large)
                .floatIdle()
                Text("Here we go…")
                    .font(Typeface.display(scale(Metrics.title)))
                    .foregroundStyle(Theme.ink)
                    .padding(.top, scale(Metrics.titleTop))
                Text(CouchCopy.starting(game.title))
                    .font(Typeface.sans(scale(Metrics.subtitle)))
                    .foregroundStyle(Theme.inkSoft)
                    .padding(.top, scale(Metrics.subtitleTop))
            }
        }
        .transition(.opacity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    CouchLaunchPhase(game: Game(title: "Lantern Coast: The Long Tide"), palette: .neutral, scale: scale)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
