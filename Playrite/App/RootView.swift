import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Top-level layout: the floating sidebar over one continuous page background (``RailShell``) + navigable content
/// (poster grid → three-column details).
struct RootView: View {
    /// App dependencies.
    let environment: AppEnvironment
    @State private var libraryViewModel: LibraryViewModel
    @State private var nxnativeViewModel: NXNativeViewModel
    @State private var selection: SidebarDestination? = .home
    @State private var path: [UUID] = []
    @Environment(\.openSettings) private var openSettings
    @State private var isAddingGame = false
    @State private var isImporting = false
    @State private var isMergingDuplicates = false
    @State private var exportDocument: LibraryJSONDocument?

    /// Creates the root view.
    init(environment: AppEnvironment) {
        self.environment = environment
        let libraryViewModel = environment.makeLibraryViewModel()
        _libraryViewModel = State(initialValue: libraryViewModel)
        _nxnativeViewModel = State(initialValue: environment.makeNXNativeViewModel { libraryViewModel.reload() })
    }

    var body: some View {
        RailShell(selection: $selection, libraryViewModel: libraryViewModel) { navigation }
            .environment(environment)
            .environment(\.onboardingGuide, environment.guide)
            .onChange(of: selection) { path.removeAll() }
            .task {
                environment.watcher.start()
                await libraryViewModel.runAutomaticUpkeep()
            }
            .modifier(GuideHost(
                guide: environment.guide,
                isGameRunning: environment.handoff.isGameRunning,
                onNavigate: navigate(to:),
                onChooseFolders: addGuideFolders
            ))
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                environment.watcher.stop()
            }
            .onReceive(NotificationCenter.default.publisher(for: LibraryChangeNotification.name)) { _ in
                libraryViewModel.reload()
                Task { await libraryViewModel.fetchMetadataQuietly() }
            }
            .toolbar { libraryToolbar }
            .sheet(isPresented: $isAddingGame) {
                AddGameSheet { libraryViewModel.addGame(title: $0, platform: $1, status: $2) }
            }
            .sheet(isPresented: $isMergingDuplicates) {
                MergeDuplicatesSheet(viewModel: environment.makeMergeDuplicatesViewModel { libraryViewModel.reload() })
            }
            .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], onCompletion: handleImport)
            .fileExporter(
                isPresented: exportBinding,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "Retriever Library"
            ) { _ in exportDocument = nil }
            .alert("Library", isPresented: alertBinding, presenting: alertMessage) { _ in
                Button("OK") { clearAlert() }
            } message: { Text($0) }
    }

    private var navigation: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: UUID.self) { id in
                    if let game = libraryViewModel.game(withID: id) {
                        GameDetailView(
                            viewModel: environment.makeGameDetailViewModel(for: game),
                            launchViewModel: environment.makeGameLaunchViewModel(for: game)
                        )
                        .id(id)
                    }
                }
        }
    }

    @ViewBuilder private var content: some View {
        switch selection {
        case .home:
            HomeView(
                libraryViewModel: libraryViewModel,
                makeLaunch: environment.makeGameLaunchViewModel(for:),
                onAddGame: { isAddingGame = true },
                onBrowseLibrary: { selection = .library(.all) }
            )
        case let .library(section):
            LibraryGridView(viewModel: libraryViewModel)
                .onAppear { libraryViewModel.filter.section = section }
                .onChange(of: section) { libraryViewModel.filter.section = section }
        case .series:
            SeriesListView(viewModel: environment.makeSeriesListViewModel())
        case .collections:
            CollectionsListView(viewModel: environment.makeCollectionsViewModel())
        case .stats:
            StatsView(viewModel: environment.makeStatsViewModel())
        case .steam:
            SteamDashboardView(
                viewModel: environment.makeSteamDashboardViewModel { libraryViewModel.reload() },
                connection: environment.makeSteamConnectionViewModel()
            )
        case .tracking:
            TrackingDashboardView(viewModel: environment.makeTrackingViewModel { libraryViewModel.reload() })
        case .nxnative:
            NXNativeDashboardView(viewModel: nxnativeViewModel)
        case nil:
            EmptyStateView(title: "Pick a section", symbolName: "sidebar.left")
        }
    }

    @ToolbarContentBuilder private var libraryToolbar: some ToolbarContent {
        ToolbarItemGroup {
            Button("Add Game", systemImage: "plus") { isAddingGame = true }
            Menu("Library File", systemImage: "square.and.arrow.up.on.square") {
                Button("Import Library…") { isImporting = true }
                Button("Export Library…") {
                    exportDocument = libraryViewModel.exportData().map(LibraryJSONDocument.init(data:))
                }
                Divider()
                Button("Scan Game Folders") { Task { await libraryViewModel.scanGameFolders() } }
                    .disabled(!libraryViewModel.canScanFolders)
                SettingsLink { Text("Configure Game Folders…") }
                Divider()
                Button("Merge Duplicate Games…") { isMergingDuplicates = true }
                Button("Fetch Missing Metadata") { Task { await libraryViewModel.fetchMissingMetadata() } }
                    .disabled(!libraryViewModel.canFetchMetadata)
            }
            .guideHotspot(.gameFolders)
        }
    }

    private var exportBinding: Binding<Bool> {
        Binding(get: { exportDocument != nil }, set: {
            if !$0 {
                exportDocument = nil
            }
        })
    }

    private var alertMessage: String? {
        libraryViewModel.errorMessage
            ?? libraryViewModel.importSummary?.description
            ?? libraryViewModel.folderImportSummary?.description
            ?? libraryViewModel.metadataSummary?.description
    }

    /// Alerts never appear over a running game; they wait until Retriever is back (ADR 0030 Layer 1).
    private var alertBinding: Binding<Bool> {
        Binding(get: { alertMessage != nil && !environment.handoff.isGameRunning }, set: {
            if !$0 {
                clearAlert()
            }
        })
    }

    private func clearAlert() {
        libraryViewModel.errorMessage = nil
        libraryViewModel.importSummary = nil
        libraryViewModel.folderImportSummary = nil
        libraryViewModel.metadataSummary = nil
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case let .success(url):
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            do {
                try libraryViewModel.importLibrary(from: Data(contentsOf: url))
            } catch {
                libraryViewModel.errorMessage = error.localizedDescription
            }
        case let .failure(error):
            libraryViewModel.errorMessage = error.localizedDescription
        }
    }

    /// Moves to the place a tour step describes (ADR 0040). The game page step uses a game with cover art when there
    /// is one, and is skipped when the library is empty.
    private func navigate(to destination: GuideDestination) {
        switch destination {
        case .home:
            selection = .home
        case .library:
            selection = .library(.all)
        case .gamePage:
            let games = libraryViewModel.games
            guard let game = games.first(where: { $0.coverImagePath != nil }) ?? games.first else {
                environment.guide.skipStep()
                return
            }
            selection = .library(.all)
            Task {
                // After the selection change has cleared the path.
                await Task.yield()
                path = [game.id]
            }
        case .builds:
            selection = .nxnative
        case .steamSettings:
            openSettings()
        }
    }

    /// The library step's real action: the chosen folders are added and scanned, then the tour moves on.
    private func addGuideFolders(_ urls: [URL]) {
        let folders = environment.makeGameFoldersViewModel()
        folders.add(urls)
        Task { await folders.scan() }
        environment.guide.advance()
    }
}

#Preview {
    let environment = AppEnvironment.preview
    RootView(environment: environment)
        .modelContainer(environment.container)
}
