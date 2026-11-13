import SwiftUI
import UniformTypeIdentifiers

/// The sheets, file panels and alerts the menu bar opens on the main window: Add Game, Merge Duplicates, the tool
/// sheets, Import and Export Library, and one alert for library results and launch failures — never over a running game
/// (ADR 0030).
struct RootPresentations: ViewModifier {
    /// App dependencies.
    let environment: AppEnvironment
    /// The shared library.
    let libraryViewModel: LibraryViewModel
    /// The shell (presentation state).
    @Bindable var shell: ShellViewModel

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $shell.isAddingGame) {
                AddGameSheet { libraryViewModel.addGame(title: $0, platform: $1, status: $2) }
            }
            .sheet(isPresented: $shell.isMergingDuplicates) {
                MergeDuplicatesSheet(viewModel: environment.makeMergeDuplicatesViewModel { libraryViewModel.reload() })
            }
            .sheet(item: toolBinding) { tool in
                ToolSheetView(tool: tool, environment: environment)
            }
            .fileImporter(isPresented: $shell.isImporting, allowedContentTypes: [.json], onCompletion: handleImport)
            .fileExporter(
                isPresented: exportBinding,
                document: shell.exportDocument,
                contentType: .json,
                defaultFilename: "nativehaul Library"
            ) { _ in shell.exportDocument = nil }
            .alert(alertTitle, isPresented: alertBinding, presenting: alertMessage) { _ in
                Button("OK") { clearAlert() }
            } message: { Text($0) }
    }

    /// Tool sheets wait while a game runs, like every other sheet (ADR 0030 Layer 1).
    private var toolBinding: Binding<ToolSheet?> {
        Binding(
            get: { environment.handoff.isGameRunning ? nil : shell.presentedTool },
            set: { shell.presentedTool = $0 }
        )
    }

    private var exportBinding: Binding<Bool> {
        Binding(get: { shell.exportDocument != nil }, set: {
            if !$0 {
                shell.exportDocument = nil
            }
        })
    }

    private var alertTitle: String {
        shell.launchError == nil ? "Library" : "Couldn't start the game"
    }

    private var alertMessage: String? {
        shell.launchError
            ?? libraryViewModel.errorMessage
            ?? libraryViewModel.importSummary?.description
            ?? libraryViewModel.folderImportSummary?.description
            ?? libraryViewModel.metadataSummary?.description
    }

    /// Alerts never appear over a running game; they wait until nativehaul is back (ADR 0030 Layer 1).
    private var alertBinding: Binding<Bool> {
        Binding(get: { alertMessage != nil && !environment.handoff.isGameRunning }, set: {
            if !$0 {
                clearAlert()
            }
        })
    }

    private func clearAlert() {
        if shell.launchError != nil {
            shell.launchError = nil
            return
        }
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
}
