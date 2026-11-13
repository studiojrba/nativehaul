import SwiftUI

/// Builds (spec §3.4): the list a third wide on the left, the selected build on its game's wash panel on the right.
/// The engine is found by itself (ADR 0021/0027): a missing engine is a plain "Choose…" state above the build, never a
/// setup step; switched off in Settings, the page offers to turn it back on. Add a build and the tools sit with the
/// list; each build's checks, files, tidy-up and log sit under its progress.
struct BuildsScreen: View {
    /// The page state.
    let viewModel: BuildsViewModel
    /// The title to select on arrival (from Detail's build link), taken once.
    var focusTitleID: String?
    /// Tells the shell the focus was taken.
    var focusTaken: () -> Void = {}

    @Environment(AppEnvironment.self) private var environment
    @Environment(\.gameTones) private var tones
    @State private var sheet: BuildsSheet?
    @State private var isChoosingEngine = false

    private typealias Metrics = ShellLayout.Builds

    var body: some View {
        Group {
            if viewModel.queue.readiness == .switchedOff {
                NXNativeSwitchedOffView { viewModel.queue.turnOn() }
                    .padding(.leading, ShellLayout.Chrome.islandClearance)
                    .padding(.top, ShellLayout.Chrome.topBarClearance)
            } else {
                columns
            }
        }
        .onAppear {
            viewModel.queue.refreshReadiness()
            viewModel.focus(titleID: focusTitleID)
            focusTaken()
        }
        .fileImporter(isPresented: $isChoosingEngine, allowedContentTypes: [.item]) { result in
            if case let .success(url) = result {
                viewModel.queue.chooseEngine(at: url.path)
            }
        }
        .sheet(item: $sheet) { sheet in
            sheetView(sheet)
        }
    }

    private var columns: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                BuildsListColumn(
                    viewModel: viewModel,
                    addBuild: { sheet = .addBuild },
                    openKnownIssues: { sheet = .knownIssues },
                    chooseEngine: { isChoosingEngine = true }
                )
                .frame(width: max(Metrics.listMinWidth, (proxy.size.width - Metrics.listLeading) * Metrics.listShare)
                    + Metrics.listLeading)
                detailColumn(pageSize: proxy.size)
            }
        }
    }

    private func detailColumn(pageSize: CGSize) -> some View {
        let job = viewModel.selectedJob
        let palette = job.map(viewModel.palette(for:)) ?? .neutral
        return ZStack {
            RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous)
                .fill(tones.wash(palette).color)
                .overlay {
                    WashBackground(colors: [
                        tones.lift(Metrics.washLiftFirst),
                        tones.glow(palette),
                        tones.lift(Metrics.washLiftLast),
                    ])
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous))
                }
                .padding(.vertical, Metrics.panelInset)
                .padding(.trailing, Metrics.panelInset)
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    if viewModel.queue.readiness == .engineNotFound {
                        EngineNotFoundBanner { isChoosingEngine = true }
                            .clipShape(RoundedRectangle(cornerRadius: KitMetrics.Radius.card, style: .continuous))
                    }
                    if let job {
                        BuildsDetailPanel(viewModel: viewModel, job: job, pageSize: pageSize) { entry in
                            sheet = .troubleshoot(entry)
                        }
                    } else {
                        BuildsEmptyPanel { sheet = .addBuild }
                    }
                }
                .padding(.horizontal, Metrics.contentHorizontal)
                .padding(.top, Metrics.detailTop - Metrics.panelInset + Metrics.contentTop)
                .padding(.bottom, Metrics.detailBottom)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, Metrics.panelInset)
            .padding(.trailing, Metrics.panelInset)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.panelRadius, style: .continuous))
            .padding(.trailing, Metrics.detailTrailing - Metrics.panelInset)
            .animation(Motion.fade, value: job?.id)
        }
    }

    @ViewBuilder
    private func sheetView(_ sheet: BuildsSheet) -> some View {
        switch sheet {
        case .addBuild:
            AddBuildJobSheet(viewModel: AddBuildViewModel(files: viewModel.queue.services.files)) {
                viewModel.queue.enqueue(sourcePath: $0, title: $1)
            }
        case .knownIssues:
            BuildsKnownIssuesSheet(cases: viewModel.queue.knowledgeBase) { self.sheet = .troubleshoot($0) }
        case let .troubleshoot(entry):
            TroubleshootingView(viewModel: environment.makeTroubleshootingViewModel(for: entry) {
                if let id = viewModel.selectedJob?.id {
                    viewModel.queue.requeue(id)
                    viewModel.queue.startQueue()
                }
            })
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    BuildsScreen(viewModel: BuildsViewModel(
        queue: environment.makeNXNativeViewModel {},
        library: { [] },
        paletteExtractor: MockGamePaletteExtractor()
    ))
    .environment(environment)
    .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
