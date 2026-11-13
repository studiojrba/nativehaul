import SwiftUI

/// The selected build on its wash panel (spec §3.4): the screenshot slideshow, the header, the six-stage bar with the
/// current stage's explanation, the stat cards, then the build's tools. The panel takes the game's wash with lifts;
/// its content fades in when the selection changes.
struct BuildsDetailPanel: View {
    /// The page state.
    let viewModel: BuildsViewModel
    /// The build.
    let job: BuildJob
    /// The window's size (title and slideshow scale with it).
    let pageSize: CGSize
    /// Opens a troubleshooting case.
    let troubleshoot: (TroubleshootingCase) -> Void

    private typealias Metrics = ShellLayout.Builds

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let showcase = viewModel.showcase(for: job) {
                BuildShowcaseView(showcase: showcase, stageHeight: stageHeight)
                    .padding(.bottom, Metrics.headerTop)
            }
            BuildsJobHeader(viewModel: viewModel, job: job, pageWidth: pageSize.width)
            SegmentedStageBar(
                segments: viewModel.segments(for: job),
                explanation: job.pipeline.stage == .ready ? nil : job.pipeline.stage.explanation
            )
            .padding(.top, Metrics.progressTop)
            HStack(spacing: Metrics.statsGap) {
                ForEach(viewModel.stats(for: job), id: \.label) { stat in
                    StatCard(label: stat.label, value: stat.value)
                }
            }
            .padding(.top, Metrics.statsTop)
            BuildsJobTools(queue: viewModel.queue, job: job, troubleshoot: troubleshoot)
                .padding(.top, Metrics.toolsTop)
        }
        .id(job.id)
        .transition(.opacity)
        .task(id: job.id) { await viewModel.loadPalette(for: job) }
    }

    private var stageHeight: CGFloat {
        min(Metrics.stageMax, max(Metrics.stageMin, pageSize.height * Metrics.stageShare))
    }
}

#Preview {
    let environment = AppEnvironment.preview
    BuildsDetailPanel(
        viewModel: BuildsViewModel(
            queue: environment.makeNXNativeViewModel {},
            library: { [] },
            paletteExtractor: MockGamePaletteExtractor()
        ),
        job: BuildJob(
            sourcePath: "/s/a.nsp",
            title: TitleInfo(titleID: "0100000000010000", name: "Lantern Coast", architecture: .bit64)
        ),
        pageSize: CGSize(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight),
        troubleshoot: { _ in }
    )
    .padding(DesignTokens.Spacing.xl)
}
