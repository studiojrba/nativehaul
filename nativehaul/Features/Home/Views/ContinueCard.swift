import SwiftUI

/// A Continue playing card (spec §3.1): a 4:3 screenshot tile (the game's wide art, else its cover) that zooms a touch
/// on hover, with a frost info bar — short title, "{last played} · {playtime}" — and a round Play button.
struct ContinueCard: View {
    /// The game.
    let game: Game
    /// Its quiet line.
    let line: String
    /// Card width.
    let width: CGFloat
    /// Opens Detail.
    let open: () -> Void
    /// Plays the game.
    let play: () -> Void

    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ShelfCardButton(action: open) {
            ZStack(alignment: .bottom) {
                ArtworkFill(path: HomeViewModel.tileArtPath(for: game), title: game.title)
                    .scaleEffect(isHovered && !reduceMotion ? ShellLayout.Continue.hoverScale : 1)
                    .animation(Motion.settle(Motion.Duration.slow), value: isHovered)
                infoBar
            }
            .frame(width: width, height: width / ShellLayout.Continue.aspectRatio)
            .clipShape(RoundedRectangle(cornerRadius: ShellLayout.Continue.radius, style: .continuous))
            .elevation(.regular)
        }
        .onHover { isHovered = $0 }
        .accessibilityLabel(game.title)
    }

    private var infoBar: some View {
        HStack(spacing: ShellLayout.Chrome.innerGap) {
            VStack(alignment: .leading, spacing: 0) {
                Text(ShortTitle.make(from: game.title))
                    .font(Typeface.sans(TypeStyle.Size.label, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(DesignTokens.Lines.single)
                if !line.isEmpty {
                    Text(line)
                        .font(Typeface.sans(TypeStyle.Size.caption))
                        .foregroundStyle(Theme.inkMute)
                        .lineLimit(DesignTokens.Lines.single)
                }
            }
            Spacer(minLength: 0)
            RoundPlayButton(isHighlighted: false, action: play)
        }
        .padding(.horizontal, ShellLayout.Continue.infoHorizontal)
        .padding(.vertical, ShellLayout.Continue.infoVertical)
        .frostedGlass(in: RoundedRectangle(cornerRadius: ShellLayout.Continue.infoRadius, style: .continuous))
        .padding(ShellLayout.Continue.infoInset)
    }
}

#Preview {
    AppearancePreviewPair {
        ContinueCard(
            game: Game(title: "Lantern Coast"),
            line: "Yesterday · 11h 40m",
            width: DesignTokens.Cover.detailWidth,
            open: {},
            play: {}
        )
        .padding(KitMetrics.Spacing.section)
    }
}
