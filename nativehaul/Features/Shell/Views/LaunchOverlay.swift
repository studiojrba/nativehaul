import SwiftUI

/// The desktop launch overlay (spec §3.0): the window dims to `paper` 40% under a heavy blur and a frost card rises
/// with the floating cover, "Here we go…", a friendly line and a progress bar that fills over 2.4s. It stays until the
/// launch hands off or fails (``ShellViewModel``); Esc or a click dismisses it early.
struct LaunchOverlay: View {
    /// The game starting.
    let game: Game
    /// Dismisses the overlay.
    let dismiss: () -> Void

    @State private var progress = 0.0

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            Theme.paper.opacity(ShellLayout.LaunchOverlay.scrimOpacity)
            card.riseIn()
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture(perform: dismiss)
        .onExitCommand(perform: dismiss)
        .onAppear {
            progress = 1
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isModal)
    }

    private var card: some View {
        HStack(spacing: ShellLayout.LaunchOverlay.gap) {
            ArtworkFill(path: game.coverImagePath, title: game.title, placeholderSize: TypeStyle.Size.small)
                .aspectRatio(ShellLayout.Library.coverAspect, contentMode: .fit)
                .frame(width: ShellLayout.LaunchOverlay.coverWidth)
                .clipShape(RoundedRectangle(cornerRadius: ShellLayout.LaunchOverlay.coverRadius, style: .continuous))
                .elevation(.regular)
                .floatIdle()
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Here we go…")
                    .font(Typeface.display(TypeStyle.DisplaySize.card))
                    .foregroundStyle(Theme.ink)
                Text("Opening \(ShortTitle.make(from: game.title)). Have fun — we'll keep the shelf warm.")
                    .font(Typeface.sans(TypeStyle.Size.callout))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                PillProgressBar(
                    value: progress,
                    fillAnimation: .easeInOut(duration: ShellLayout.LaunchOverlay.progressDuration)
                )
                .frame(width: ShellLayout.LaunchOverlay.progressSize.width)
                .padding(.top, DesignTokens.Spacing.md)
            }
        }
        .padding(.vertical, ShellLayout.LaunchOverlay.cardPadding)
        .padding(.leading, ShellLayout.LaunchOverlay.cardPadding)
        .padding(.trailing, ShellLayout.LaunchOverlay.cardTrailingPadding)
        .frostedGlass(in: RoundedRectangle(cornerRadius: ShellLayout.LaunchOverlay.cardRadius, style: .continuous))
        .elevation(.large)
        .padding(KitMetrics.Spacing.page)
    }
}

#Preview {
    AppearancePreviewPair {
        LaunchOverlay(game: Game(title: "Lantern Coast: The Long Tide")) {}
    }
}
