import SwiftUI

/// The selected build's header (spec §3.4): "{version} · {size}", the title, the real job note, and on the right
/// "Ready to play" once built, or the queue's real control — Start building when it is idle, Stop when it runs. The
/// engine has no pause, so there is no Pause (ADR 0056).
struct BuildsJobHeader: View {
    /// The page state.
    let viewModel: BuildsViewModel
    /// The build.
    let job: BuildJob
    /// The window's width (the title scales with it).
    let pageWidth: CGFloat

    private typealias Metrics = ShellLayout.Builds

    var body: some View {
        HStack(alignment: .bottom, spacing: Metrics.headerGap) {
            VStack(alignment: .leading, spacing: Metrics.titleGap) {
                if let eyebrow = viewModel.eyebrow(for: job) {
                    Eyebrow(eyebrow)
                }
                DisplayHeadline(
                    lead: viewModel.game(for: job)?.title ?? job.title.name,
                    size: TypeStyle.clampedDisplay(
                        width: pageWidth,
                        min: Metrics.titleMin,
                        share: Metrics.titleWidthShare,
                        max: Metrics.titleMax
                    ),
                    lineHeight: Metrics.headerTitleLineHeight
                )
                Text(viewModel.note(for: job))
                    .font(Typeface.sans(TypeStyle.Size.callout))
                    .foregroundStyle(job.pipeline.isFailed ? Theme.danger : Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            control
        }
    }

    @ViewBuilder private var control: some View {
        if job.status == .succeeded {
            Label("Ready to play", systemImage: "checkmark")
                .font(Typeface.sans(TypeStyle.Size.body))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, Metrics.buttonHorizontal)
                .frame(height: Metrics.buttonHeight)
                .background(Capsule().fill(Theme.surface.opacity(Metrics.chipOpacity)))
                .elevation(.small)
                .fixedSize()
        } else if viewModel.canStop {
            pill("Stop building", icon: "stop.fill") { viewModel.queue.cancel() }
        } else if viewModel.canStart {
            pill("Start building", icon: "play.fill") { viewModel.queue.startQueue() }
        }
    }

    private func pill(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: icon).font(.system(size: Metrics.buttonIcon))
                Text(title)
            }
            .font(Typeface.sans(TypeStyle.Size.body))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, Metrics.buttonHorizontal)
            .frame(height: Metrics.buttonHeight)
            .frostedGlass(in: Capsule())
            .elevation(.small)
            .fixedSize()
        }
        .buttonStyle(PressButtonStyle())
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let viewModel = BuildsViewModel(
        queue: environment.makeNXNativeViewModel {},
        library: { [] },
        paletteExtractor: MockGamePaletteExtractor()
    )
    BuildsJobHeader(
        viewModel: viewModel,
        job: BuildJob(
            sourcePath: "/s/a.nsp",
            title: TitleInfo(titleID: "0100000000010000", name: "Lantern Coast", architecture: .bit64)
        ),
        pageWidth: DesignTokens.Layout.windowMinWidth
    )
    .padding(DesignTokens.Spacing.xl)
}
