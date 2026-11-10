import SwiftUI

/// Settings tab: configured game folders and the "Scan Game Folders" action.
struct GameFoldersSettingsView: View {
    @State private var viewModel: GameFoldersViewModel
    @State private var isChoosingFolders = false

    /// Creates the view.
    init(viewModel: GameFoldersViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                if viewModel.folders.isEmpty {
                    Text("No folders yet. Add the folders where your games live, e.g. ~/Switch/Games.")
                        .foregroundStyle(Theme.secondaryText)
                }
                ForEach(viewModel.folders, id: \.self) { folder in
                    GameFolderRow(folder: folder) { viewModel.remove(folder) }
                }
                Button("Add Folder…", systemImage: "plus") { isChoosingFolders = true }
            } header: {
                Text("Game Folders")
            } footer: {
                Text(
                    "Scans look up to four levels deep for game apps (existing Switch port builds are adopted as "
                        + "they are) and ROM files. Nothing on disk is changed."
                )
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
            }
            Section {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Button("Scan Game Folders", systemImage: "magnifyingglass") {
                        Task { await viewModel.scan() }
                    }
                    .disabled(viewModel.isScanning)
                    if viewModel.isScanning {
                        ProgressView().controlSize(.small)
                    }
                }
                if let summary = viewModel.lastSummary {
                    FolderImportSummaryView(summary: summary)
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Theme.danger)
                }
            }
        }
        .formStyle(.grouped)
        .fileImporter(
            isPresented: $isChoosingFolders,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: true
        ) { result in
            if case let .success(urls) = result {
                viewModel.add(urls)
            }
        }
    }
}

#Preview {
    GameFoldersSettingsView(viewModel: GameFoldersViewModel(
        store: InMemoryGameFolderStore(["/Users/demo/Switch/Games", "/Applications"]),
        importer: MockGameFolderImporter()
    ))
}
