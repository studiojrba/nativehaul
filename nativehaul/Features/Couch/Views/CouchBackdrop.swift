import SwiftUI

/// Couch's background (spec §3.7): `paper` under the focused game's wash composition — `wash(palette)` with a lift,
/// the game's glow and a second lift — crossfading over 800ms as focus moves (the hero's incoming slide on the hero,
/// the focused tile on the shelves). With no game in focus it rests on the theme's own washes.
struct CouchBackdrop: View {
    /// The game in focus, if any.
    let game: Game?
    /// Its palette.
    let palette: GamePalette

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeTokens) private var tokens

    var body: some View {
        ZStack {
            Theme.paper
            if game != nil {
                let tones = GameTones(scheme: colorScheme)
                tones.wash(palette).color
                    .animation(.easeInOut(duration: HeroTiming.wash), value: palette)
                WashBackground(
                    colors: [
                        tones.lift(CouchBackdrop.firstLift),
                        tones.glow(palette),
                        tones.lift(CouchBackdrop.secondLift),
                    ],
                    crossfade: HeroTiming.wash
                )
            } else {
                WashBackground(slots: [.sky, .cream], crossfade: HeroTiming.wash)
            }
        }
        .ignoresSafeArea()
    }

    /// The first lift's strength (`lift(0.8)`).
    static let firstLift = 0.8
    /// The second lift's strength (`lift(0.55)`).
    static let secondLift = 0.55
}

#Preview {
    AppearancePreviewPair {
        CouchBackdrop(game: Game(title: "Lantern Coast"), palette: .neutral)
            .frame(width: CouchLayout.previewHalf.width, height: CouchLayout.previewHalf.height)
    }
}
