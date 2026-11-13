import SwiftUI

/// Detail's sticky left column (spec §3.3): the game's wash with lifts, the case centred (64pt in, 40pt down) and
/// scaled to fit, and "{studio} — {year}" at the bottom left.
struct DetailVisualColumn: View {
    /// Detail's state.
    let viewModel: DetailViewModel

    @Environment(\.gameTones) private var tones

    private typealias Metrics = ShellLayout.GameCase

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                tones.wash(viewModel.palette).color
                WashBackground(colors: [
                    tones.lift(ShellLayout.Detail.washLiftFirst),
                    tones.glow(viewModel.palette),
                    tones.lift(ShellLayout.Detail.washLiftLast),
                ])
                GameCaseObject(
                    artwork: viewModel.caseArtwork,
                    turnHint: viewModel.turnHint,
                    scale: Self.scale(for: proxy.size)
                )
                .padding(.leading, ShellLayout.Detail.caseLeading)
                .padding(.top, ShellLayout.Detail.caseTop)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                if let caption = viewModel.caption {
                    Text(caption.uppercased())
                        .font(Typeface.sans(TypeStyle.Size.caption))
                        .tracking(TypeStyle.tracking(em: TypeStyle.Eyebrow.trackingEm, size: TypeStyle.Size.caption))
                        .foregroundStyle(Theme.ink.opacity(ShellLayout.Detail.captionOpacity))
                        .lineLimit(1)
                        .padding(.leading, ShellLayout.Detail.captionLeading)
                        .padding(.bottom, ShellLayout.Detail.captionBottom)
                }
            }
        }
        .clipped()
        .task(id: viewModel.game.coverImagePath) { await viewModel.loadPalette() }
    }

    /// The case's scale: its reference size, shrunk to fit the column (never below the minimum).
    static func scale(for size: CGSize) -> CGFloat {
        let width = size.width - ShellLayout.Detail.caseLeading
        let height = size.height - ShellLayout.Detail.caseTop - Metrics.turnButtonRoom
        let fit = min(
            width / (Metrics.width + Metrics.areaExtraWidth),
            height / (Metrics.height + Metrics.areaExtraHeight)
        )
        return min(1, max(Metrics.minimumScale, fit))
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        DetailVisualColumn(viewModel: environment.makeDetailViewModel(for: game, buildBadge: { nil }, library: { [] }))
            .frame(width: DesignTokens.Layout.detailMinWidth, height: DesignTokens.Layout.windowMinHeight)
    }
}
