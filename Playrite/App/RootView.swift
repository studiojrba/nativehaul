import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Top-level split view: sidebar + navigable content.
struct RootView: View {
    /// App dependencies.
    let environment: AppEnvironment
    @State private var libraryViewModel: LibraryViewModel
    @State private var selection: SidebarDestination? = .library(.all)
    @State private var path: [UUID] = []
    @State private var isAddingGame = false
    @State private var isImporting = false
    @State private var exportDocument: LibraryJSONDocument?

    /// Creates the root view.
    init(environment: AppEnvironment) {
        self.environment = environment
        _libraryViewModel = State(initialValue: environment.makeLibraryViewModel())
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, libraryViewModel: libraryViewModel)
        } detail: {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(for: UUID.self) { id in
                        if let game = libraryViewModel.game(withID: id) {
                            GameDetailView(viewModel: GameDetailViewModel(
                                game: game,
                                repository: environment.repository
                            ))
                        }
                    }
            }
        }
        .environment(environment)
        .onChange(of: selection) { path.removeAll() }
        .toolbar { libraryToolbar }
        .sheet(isPresented: $isAddingGame) {
            AddGameSheet { libraryViewModel.addGame(title: $0, platform: $1, status: $2) }
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], onCompletion: handleImport)
        .fileExporter(
            isPresented: exportBinding,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "Playrite Library"
        ) { _ in exportDocument = nil }
        .alert("Library", isPresented: alertBinding, presenting: alertMessage) { _ in
            Button("OK") { clearAlert() }
        } message: { Text($0) }
    }

    @ViewBuilder private var content: some View {
        switch selection {
        case let .library(section):
            LibraryGridView(viewModel: libraryViewModel)
                .onAppear { libraryViewModel.filter.section = section }
                .onChange(of: section) { libraryViewModel.filter.section = section }
        case .steam:
            SteamDashboardView(viewModel: environment.makeSteamDashboardViewModel { libraryViewModel.reload() })
        case nil:
            ContentUnavailableView("Select a Section", systemImage: "sidebar.left")
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
            }
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
        libraryViewModel.errorMessage ?? libraryViewModel.importSummary?.description
    }

    private var alertBinding: Binding<Bool> {
        Binding(get: { alertMessage != nil }, set: {
            if !$0 {
                clearAlert()
            }
        })
    }

    private func clearAlert() {
        libraryViewModel.errorMessage = nil
        libraryViewModel.importSummary = nil
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
}

#Preview {
    let environment = AppEnvironment.preview
    RootView(environment: environment)
        .modelContainer(environment.container)
}
