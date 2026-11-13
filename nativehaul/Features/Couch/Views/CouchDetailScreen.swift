import SwiftUI

/// Couch Detail (ADR 0058, undesigned — derived from §3.3 at 10-foot scale): the standing case turned toward the
/// viewer, then "{genre} · {year}", the title, the real summary, the first key specs and the buttons — Play (when the
/// game can start) and Favourite. A game that can't start says why; the fix is a desk job.
struct CouchDetailScreen: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    private typealias Metrics = CouchLayout.Detail

    var body: some View {
        let scale = viewModel.scale
        if let detail = viewModel.detail, detail.game.id == viewModel.state.detailGameID {
            HStack(alignment: .center, spacing: scale(Metrics.columnGap)) {
                StandingCase(
                    coverPath: detail.game.coverImagePath,
                    title: detail.game.title,
                    palette: viewModel.palette(for: detail.game),
                    isTurned: true
                )
                .frame(width: scale.height(Metrics.caseWidthShare))
                text(detail, scale: scale)
                    .frame(maxWidth: scale(Metrics.textMaxWidth), alignment: .leading)
            }
            .padding(.horizontal, scale(CouchLayout.gutter))
            .padding(.bottom, scale(Metrics.bottomInset))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func text(_ detail: DetailViewModel, scale: CouchScale) -> some View {
        VStack(alignment: .leading, spacing: scale(Metrics.blockGap)) {
            VStack(alignment: .leading, spacing: scale(CouchLayout.Hero.headlineTop)) {
                if let eyebrow = detail.eyebrow {
                    Eyebrow(eyebrow, size: scale(CouchLayout.Page.eyebrow))
                }
                DisplayHeadline(lead: detail.game.title, size: scale(Metrics.title))
            }
            if let summary = detail.summary {
                Text(summary)
                    .font(Typeface.sans(scale(Metrics.summary)))
                    .foregroundStyle(Theme.inkSoft)
                    .lineLimit(Metrics.summaryLines)
            }
            specs(detail.specs, scale: scale)
            if let note = launchNote(detail) {
                Text(note)
                    .font(Typeface.sans(scale(Metrics.summary)))
                    .foregroundStyle(Theme.inkMute)
            }
            buttons(detail, scale: scale)
        }
    }

    /// Why the game can't start from the sofa, if it can't: the planner's reason, or the file only the user can
    /// provide (the picker lives at the desk).
    private func launchNote(_ detail: DetailViewModel) -> String? {
        if let reason = detail.launch.unavailableReason {
            return reason
        }
        return detail.launch.fileRequest.map { "\($0.prompt) at the desk. \($0.reason)" }
    }

    private func specs(_ rows: [DetailSpecRow], scale: CouchScale) -> some View {
        VStack(spacing: 0) {
            ForEach(rows.prefix(Metrics.specLimit)) { row in
                HStack(alignment: .firstTextBaseline) {
                    Text(row.label)
                        .font(Typeface.sans(scale(Metrics.specLabel)))
                        .foregroundStyle(Theme.inkMute)
                    Spacer(minLength: scale(Metrics.blockGap))
                    Text(row.value)
                        .font(Typeface.sans(scale(Metrics.specValue)))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                }
                .padding(.vertical, scale(Metrics.specRowPadding))
                .overlay(alignment: .bottom) { HairlineDivider() }
            }
        }
    }

    private func buttons(_ detail: DetailViewModel, scale: CouchScale) -> some View {
        let actions = viewModel.detailActions
        let focused = viewModel.state.area == .content ? actions[safe: viewModel.state.detailIndex] : nil
        return HStack(spacing: scale(Metrics.buttonGap)) {
            ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                switch action {
                case .play:
                    CouchActionButton(
                        title: detail.playLabel,
                        symbol: "play.fill",
                        isPrimary: true,
                        isFocused: focused == .play,
                        scale: scale
                    )
                case .favorite:
                    CouchActionButton(
                        title: detail.isFavorite ? "Favourite" : "Add to favourites",
                        symbol: detail.isFavorite ? "heart.fill" : "heart",
                        isPrimary: false,
                        isFocused: focused == .favorite,
                        scale: scale
                    )
                }
            }
        }
        .padding(.top, scale(Metrics.buttonsTop))
    }
}

#Preview {
    let viewModel = CouchViewModel.preview
    if let game = viewModel.library.games.first {
        viewModel.openDetail(game.id)
    }
    return CouchDetailScreen(viewModel: viewModel)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
