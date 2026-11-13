import SwiftUI

/// Detail's title block (spec §3.3): "{genre} · {year}", the title in display type sized to the window, and the
/// real description. There is no tagline: nothing in the library supplies one, so none is invented.
struct DetailHeader: View {
    /// Detail's state.
    let viewModel: DetailViewModel
    /// The window's width (the title scales with it).
    let pageWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let eyebrow = viewModel.eyebrow {
                Eyebrow(eyebrow)
                    .padding(.bottom, ShellLayout.Detail.titleTop)
            }
            DisplayHeadline(
                lead: viewModel.game.title,
                size: TypeStyle.clampedDisplay(
                    width: pageWidth,
                    min: ShellLayout.Detail.titleMin,
                    share: ShellLayout.Detail.titleWidthShare,
                    max: ShellLayout.Detail.titleMax
                ),
                lineHeight: ShellLayout.Detail.titleLineHeight,
                trackingEm: ShellLayout.Detail.titleTrackingEm
            )
            if let summary = viewModel.summary {
                Text(summary)
                    .font(Typeface.sans(TypeStyle.Size.lead))
                    .lineSpacing(ShellLayout.Detail.descriptionLineSpacing)
                    .foregroundStyle(Theme.inkSoft)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: ShellLayout.Detail.descriptionMaxWidth, alignment: .leading)
                    .padding(.top, ShellLayout.Detail.descriptionTop)
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        AppearancePreviewPair {
            DetailHeader(
                viewModel: environment.makeDetailViewModel(for: game, buildBadge: { nil }, library: { [] }),
                pageWidth: DesignTokens.Layout.windowMinWidth
            )
            .padding(DesignTokens.Spacing.xl)
        }
    }
}
