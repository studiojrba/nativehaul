import SwiftUI

/// A game's TV detail screen (ADR 0052): the Builds-page media, the title, a short description and how it will open.
struct TVDetailView: View {
    /// The game.
    let game: Game
    /// Screen metrics.
    let metrics: TVMetrics

    var body: some View {
        HStack(alignment: .top, spacing: metrics.doubleGap) {
            TVGameMediaView(game: game, maxHeight: metrics.detailMediaHeight)
                .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: metrics.gap) {
                Text(game.title)
                    .font(metrics.titleFont)
                    .lineLimit(DesignTokens.Lines.title)
                Text(subtitle)
                    .font(metrics.bodyEmphasisFont)
                    .foregroundStyle(Theme.secondaryText)
                if !game.summary.isEmpty {
                    Text(game.summary)
                        .font(metrics.bodyFont)
                        .lineLimit(DesignTokens.Lines.summary)
                }
                Label(
                    game.launchesWindowedInTVMode ? "Opens in a window (set in desktop mode)" : "Opens full screen",
                    systemImage: game.launchesWindowedInTVMode ? "macwindow" : "arrow.up.left.and.arrow.down.right"
                )
                .font(metrics.bodyFont)
                .foregroundStyle(Theme.secondaryText)
            }
            .frame(width: metrics.menuWidth, alignment: .leading)
        }
        .foregroundStyle(Theme.primaryText)
    }

    private var subtitle: String {
        let system = game.emulatedSystem?.displayName ?? game.platform.displayName
        return "\(system) · \(game.status.displayName)"
    }
}

#Preview {
    TVDetailView(
        game: Game(title: "Tideborn", platform: .switchPort, summary: "A sea-faring adventure."),
        metrics: TVMetrics(size: DesignTokens.TVMode.previewScreen)
    )
    .padding(DesignTokens.Spacing.xxl)
    .background(Theme.canvas)
}
