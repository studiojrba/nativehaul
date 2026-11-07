import SwiftUI

/// NXNative sidebar screen: build queue, job detail and knowledge base.
struct NXNativeDashboardView: View {
    /// Queue state (owned by the root view so the queue survives navigation).
    @Bindable var viewModel: NXNativeViewModel
    /// Game files waiting in the watched folder (ADR 0024).
    let inbox: BuildsInboxViewModel
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
        .onAppear {
            viewModel.refreshReadiness()
            inbox.start()
        }
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

    private var content: some View {
        HSplitView {
            List(selection: $viewModel.selectedJobID) {
                if inbox.watchedFolder != nil {
                    BuildsInboxSection(inbox: inbox)
                }
                Section("Queue") {
                    ForEach(viewModel.jobs) { BuildJobRow(job: $0).tag($0.id) }
                }
                Section {
                    KnowledgeBaseView(cases: viewModel.knowledgeBase) { openCase = $0 }
                }
            }
            .frame(minWidth: DesignTokens.Layout.sidebarMinWidth)
            Group {
                if let job = viewModel.selectedJob {
                    BuildJobDetailView(job: job, viewModel: viewModel) { openCase = $0 }
                } else {
                    ContentUnavailableView(
                        "No Job Selected",
                        systemImage: "hammer",
                        description: Text("Add a staged title to the queue.")
                    )
                }
            }
            .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        }
        .toolbar {
            Button("Add Job", systemImage: "plus") { isAddingJob = true }
            if viewModel.isProcessing {
                Button("Cancel Build", systemImage: "stop.fill") { viewModel.cancel() }
            } else {
                Button("Start Queue", systemImage: "play.fill") { viewModel.startQueue() }
                    .disabled(!viewModel.jobs.contains { $0.status == .queued })
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let queue = environment.makeNXNativeViewModel {}
    NXNativeDashboardView(viewModel: queue, inbox: environment.makeBuildsInboxViewModel(queue: queue))
        .environment(environment)
}
