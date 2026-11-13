import SwiftUI

/// NXNative sidebar screen: build queue, job detail and knowledge base.
struct NXNativeDashboardView: View {
    /// Queue state (owned by the root view so the queue survives navigation).
    @Bindable var viewModel: NXNativeViewModel
    @Environment(AppEnvironment.self) private var environment
    @State private var isAddingJob = false
    @State private var openCase: TroubleshootingCase?
    @State private var isChoosingEngine = false

    var body: some View {
        Group {
            if viewModel.readiness == .switchedOff {
                NXNativeSwitchedOffView { viewModel.turnOn() }
            } else {
                VStack(spacing: DesignTokens.Spacing.none) {
                    if viewModel.readiness == .engineNotFound {
                        EngineNotFoundBanner { isChoosingEngine = true }
                    }
                    content
                }
            }
        }
        .navigationTitle("NXNative Builds")
        .onAppear { viewModel.refreshReadiness() }
        .fileImporter(isPresented: $isChoosingEngine, allowedContentTypes: [.item]) { result in
            if case let .success(url) = result {
                viewModel.chooseEngine(at: url.path)
            }
        }
        .sheet(isPresented: $isAddingJob) {
            AddBuildJobSheet(viewModel: AddBuildViewModel(files: viewModel.services.files)) {
                viewModel.enqueue(sourcePath: $0, title: $1)
            }
        }
        .sheet(item: $openCase) { entry in
            TroubleshootingView(viewModel: environment.makeTroubleshootingViewModel(for: entry) {
                if let id = viewModel.selectedJobID {
                    viewModel.requeue(id)
                    viewModel.startQueue()
                }
            })
        }
    }

    /// Fixed parents (QA Finding #2 contract): the queue keeps a third of the page, the job detail two thirds.
    private var content: some View {
        VStack(spacing: DesignTokens.Spacing.none) {
            actions
            HairlineDivider()
            columns
        }
    }

    private var columns: some View {
        GeometryReader { proxy in
            let detailWidth = (proxy.size.width * DesignTokens.Builds.detailShare).rounded(.down)
            HStack(spacing: DesignTokens.Spacing.none) {
                queueColumn
                    .frame(width: proxy.size.width - detailWidth - DesignTokens.Stroke.hairline)
                HairlineDivider(axis: .vertical)
                detailColumn
                    .frame(width: detailWidth)
                    .clipped()
            }
        }
    }

    private var queueColumn: some View {
        List(selection: $viewModel.selectedJobID) {
            Section("Queue") {
                ForEach(viewModel.jobs) { BuildJobRow(job: $0).tag($0.id) }
            }
            Section {
                KnowledgeBaseView(cases: viewModel.knowledgeBase) { openCase = $0 }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.surface)
    }

    private var detailColumn: some View {
        Group {
            if let job = viewModel.selectedJob {
                BuildJobDetailView(job: job, viewModel: viewModel) { openCase = $0 }
            } else {
                EmptyStateView(
                    title: "Nothing selected",
                    symbolName: "hammer",
                    message: "Queue a game from the list, or use Add Job."
                )
            }
        }
        .background(Theme.canvas)
    }

    /// The queue's actions (a toolbar before the 0.1.0 shell hid the title bar).
    private var actions: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Spacer(minLength: 0)
            Button("Add Job", systemImage: "plus") { isAddingJob = true }
            if viewModel.isProcessing {
                Button("Cancel Build", systemImage: "stop.fill") { viewModel.cancel() }
            } else {
                Button("Start Queue", systemImage: "play.fill") { viewModel.startQueue() }
                    .disabled(!viewModel.jobs.contains { $0.status == .queued })
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Theme.surface)
    }
}

#Preview {
    let environment = AppEnvironment.preview
    NXNativeDashboardView(viewModel: environment.makeNXNativeViewModel {})
        .environment(environment)
}
