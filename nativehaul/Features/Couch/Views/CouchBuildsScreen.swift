import SwiftUI

/// Couch Builds (ADR 0058, undesigned — derived from §3.4): the builds list on the left and the selected build's panel
/// on its wash — cover, title, the real job note and the segmented progress. Starting, stopping and adding builds stay
/// at the desk (they need files and choices); A opens the build's game.
struct CouchBuildsScreen: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    private typealias Metrics = CouchLayout.Builds

    var body: some View {
        let scale = viewModel.scale
        let jobs = viewModel.buildJobs
        VStack(alignment: .leading, spacing: scale(CouchLayout.Page.contentTop)) {
            CouchPageHeader(eyebrow: "Builds", title: "In the oven.", subtitle: viewModel.builds.subtitle, scale: scale)
            if jobs.isEmpty {
                CouchEmptyState(
                    title: "Nothing in the oven",
                    message: "Builds you start at the desk show up here.",
                    scale: scale
                )
            } else {
                HStack(alignment: .top, spacing: scale(Metrics.columnGap)) {
                    list(jobs, scale: scale)
                    if let job = jobs[safe: viewModel.state.buildsIndex] {
                        panel(job, scale: scale)
                    }
                }
            }
        }
        .padding(.horizontal, scale(CouchLayout.gutter))
        .padding(.top, scale(CouchLayout.Page.top))
        .padding(.bottom, scale(CouchLayout.Page.bottomClearance))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func list(_ jobs: [BuildJob], scale: CouchScale) -> some View {
        VStack(spacing: scale(Metrics.rowGap)) {
            ForEach(Array(jobs.enumerated()), id: \.element.id) { offset, job in
                CouchBuildRow(
                    title: viewModel.builds.shortTitle(for: job),
                    detail: line(for: job),
                    coverPath: viewModel.builds.coverPath(for: job),
                    isFocused: viewModel.state.area == .content && viewModel.state.buildsIndex == offset,
                    scale: scale
                )
            }
        }
        .frame(width: scale(Metrics.listWidth))
    }

    private static let lineParts = 2

    private func line(for job: BuildJob) -> String {
        viewModel.builds.stats(for: job).map(\.value).prefix(Self.lineParts).joined(separator: " · ")
    }

    private func panel(_ job: BuildJob, scale: CouchScale) -> some View {
        let shape = RoundedRectangle(cornerRadius: scale(Metrics.panelRadius), style: .continuous)
        return VStack(alignment: .leading, spacing: scale(Metrics.blockGap)) {
            HStack(alignment: .bottom, spacing: scale(Metrics.blockGap)) {
                ArtworkFill(path: viewModel.builds.coverPath(for: job), title: viewModel.builds.shortTitle(for: job))
                    .frame(
                        width: scale(Metrics.panelCover),
                        height: scale(Metrics.panelCover) / CouchLayout.Tile.aspect
                    )
                    .clipShape(RoundedRectangle(cornerRadius: scale(CouchLayout.Tile.radius), style: .continuous))
                    .elevation(.regular)
                VStack(alignment: .leading, spacing: scale(CouchLayout.Hero.headlineTop)) {
                    if let eyebrow = viewModel.builds.eyebrow(for: job) {
                        Eyebrow(eyebrow, size: scale(CouchLayout.Page.eyebrow))
                    }
                    Text(viewModel.builds.shortTitle(for: job))
                        .font(Typeface.display(scale(Metrics.panelTitle)))
                        .foregroundStyle(Theme.ink)
                }
            }
            Text(viewModel.builds.note(for: job))
                .font(Typeface.sans(scale(Metrics.panelBody)))
                .foregroundStyle(Theme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            CouchStageBar(segments: viewModel.builds.segments(for: job), scale: scale)
        }
        .padding(scale(Metrics.panelPadding))
        .frame(maxWidth: .infinity, alignment: .leading)
        .frostedGlass(in: shape)
        .elevation(.regular)
    }
}

#Preview {
    let viewModel = CouchViewModel.preview
    viewModel.state.screen = .builds
    return CouchBuildsScreen(viewModel: viewModel)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
