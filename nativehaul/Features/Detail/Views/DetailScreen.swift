import SwiftUI

/// Game Detail (spec §3.3): the case as an object on a sticky visual column (`1.08fr`) beside a scrolling column
/// (`1fr`) — back pill, title block, actions, the build link, the launch notes, the specs table, screenshots, the
/// editorial note, "Also on your shelf", and the rest of the game's tools at the end.
struct DetailScreen: View {
    /// Detail's state.
    let viewModel: DetailViewModel
    /// Back to the screen Detail was opened from.
    let back: () -> Void
    /// Plays the game (default route when `nil`).
    let play: (LaunchOption?) -> Void
    /// Opens another game's Detail.
    let open: (Game) -> Void
    /// Opens Builds focused on this game.
    let openBuilds: () -> Void
    /// This game's build log while a build is on the way (notes 11, 15).
    var buildLog: BuildLogSnapshot?

    @State private var windowHeight: CGFloat?

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                DetailVisualColumn(viewModel: viewModel)
                    .frame(width: proxy.size.width * ShellLayout.Detail.visualShare)
                ScrollView(.vertical) {
                    column(pageWidth: proxy.size.width)
                        .padding(.horizontal, sidePadding(for: proxy.size.width))
                        .padding(.top, ShellLayout.Detail.columnTop)
                        .padding(.bottom, ShellLayout.Detail.columnBottom)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.automatic)
            }
            .onAppear { windowHeight = proxy.size.height }
            .onChange(of: proxy.size.height) { _, height in windowHeight = height }
        }
    }

    private func sidePadding(for width: CGFloat) -> CGFloat {
        width >= ShellLayout.Detail.wideWindow ? ShellLayout.Detail.columnSideWide : ShellLayout.Detail.columnSide
    }

    private func column(pageWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            BackToShelfPill(action: back)
            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(viewModel: viewModel, pageWidth: pageWidth)
                    .padding(.top, ShellLayout.Detail.eyebrowTop)
                DetailActionRow(viewModel: viewModel, play: play)
                    .padding(.top, ShellLayout.Detail.actionsTop)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    if let link = viewModel.buildState?.linkText {
                        UnderlinedLinkButton(title: link, action: openBuilds)
                    }
                    if let buildLog {
                        BuildLogPanel(
                            lines: buildLog.lines,
                            screen: .detail,
                            isLive: buildLog.isLive,
                            windowHeight: windowHeight
                        )
                        .padding(.top, ShellLayout.Detail.logTop - DesignTokens.Spacing.md)
                    }
                    DetailLaunchNotes(launch: viewModel.launch)
                }
                .padding(.top, ShellLayout.Detail.linkTop)
                DetailSpecsTable(rows: viewModel.specs)
                    .padding(.top, ShellLayout.Detail.specsTop)
                sections
            }
            .riseIn()
        }
    }

    @ViewBuilder private var sections: some View {
        let screenshots = viewModel.screenshots
        if !screenshots.isEmpty {
            DetailScreenshotsSection(paths: screenshots, title: viewModel.game.title)
                .padding(.top, ShellLayout.Detail.sectionTop)
        }
        if let note = viewModel.editorialNote {
            EditorialNoteCard(quote: note)
                .padding(.top, ShellLayout.Detail.sectionTop)
        }
        let related = viewModel.relatedGames
        if !related.isEmpty {
            AlsoOnShelfSection(games: related, open: open)
                .padding(.top, ShellLayout.Detail.sectionTop)
        }
        DetailMoreSection(viewModel: viewModel)
            .padding(.top, ShellLayout.Detail.sectionTop)
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let games = (try? environment.repository.fetchGames()) ?? []
    if let game = games.first {
        DetailScreen(
            viewModel: environment.makeDetailViewModel(for: game, buildBadge: { nil }, library: { games }),
            back: {},
            play: { _ in },
            open: { _ in },
            openBuilds: {}
        )
        .environment(environment)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
    }
}
