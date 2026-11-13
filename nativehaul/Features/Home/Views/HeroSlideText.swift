import SwiftUI

/// One slide's words and actions (spec §3.1): eyebrow, the display headline, the progress line, then Keep playing and
/// About the game.
struct HeroSlideText: View {
    /// The slide.
    let slide: HeroSlide
    /// The primary button's label.
    let playLabel: String
    /// Headline size (tracks the window width).
    let headlineSize: CGFloat
    /// Plays the game.
    let play: () -> Void
    /// Opens the game's Detail.
    let open: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow(slide.copy.eyebrow, size: TypeStyle.Eyebrow.heroSize)
            DisplayHeadline(
                lead: slide.copy.lead,
                emphasis: slide.copy.emphasis,
                trailing: slide.copy.trailing,
                size: headlineSize,
                lineHeight: TypeStyle.DisplaySize.heroLineHeight,
                trackingEm: ShellLayout.Hero.headlineTrackingEm
            )
            .padding(.top, ShellLayout.Hero.headlineTop)
            Text(slide.copy.progress)
                .font(Typeface.sans(TypeStyle.Size.lead))
                .lineSpacing(TypeStyle.leadLineSpacing)
                .foregroundStyle(Theme.inkSoft)
                .frame(maxWidth: ShellLayout.Hero.progressMaxWidth, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, ShellLayout.Hero.progressTop)
            HStack(spacing: ShellLayout.Hero.actionsGap) {
                Button(action: play) {
                    HStack(spacing: ShellLayout.Hero.playGap) {
                        Image(systemName: "play.fill").font(.system(size: KitMetrics.PillButton.iconSize))
                        Text(playLabel)
                    }
                }
                .buttonStyle(EmberButtonStyle())
                Button(action: open) {
                    HStack(spacing: ShellLayout.Hero.arrowGap) {
                        Text("About the game")
                        Image(systemName: "arrow.right").font(.system(size: ShellLayout.Hero.arrowSize))
                    }
                }
                .buttonStyle(SurfacePillButtonStyle())
            }
            .padding(.top, ShellLayout.Hero.actionsTop)
        }
    }
}

#Preview {
    let game = Game(title: "Lantern Coast")
    AppearancePreviewPair {
        HeroSlideText(
            slide: HeroSlide(game: game, copy: HeroCopyWriter.copy(for: game, now: .now)),
            playLabel: "Play",
            headlineSize: TypeStyle.DisplaySize.heroMin,
            play: {},
            open: {}
        )
        .padding(KitMetrics.Spacing.section)
    }
}
