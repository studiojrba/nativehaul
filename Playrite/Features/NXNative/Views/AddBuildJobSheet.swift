import SwiftUI

/// Folder-first Add Build (ADR 0023): choose one folder (or a lone file), see what NX Shelf understood, and queue
/// one job per game. A folder that can't be built says why, and nothing is queued.
struct AddBuildJobSheet: View {
    /// Called once per queued game with its source path and title info.
    let onAdd: (String, TitleInfo) -> Void
    @State private var viewModel: AddBuildViewModel
    @Environment(\.dismiss) private var dismiss

    /// Creates the sheet.
    init(viewModel: AddBuildViewModel, onAdd: @escaping (String, TitleInfo) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onAdd = onAdd
    }

    var body: some View {
        Form {
            Section {
                ProvideFilePrompt(request: EngineConfiguration.gameFolderRequest) { viewModel.choose($0) }
                ProvideFilePrompt(request: EngineConfiguration.gameFileRequest) { viewModel.choose($0) }
            }
            if let reason = viewModel.failureReason {
                Section {
                    Label(reason, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(Theme.warning)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else if !viewModel.games.isEmpty {
                foundSection
            }
            Picker("Architecture", selection: $viewModel.architecture) {
                ForEach(TitleArchitecture.allCases) { Text($0.displayName).tag($0) }
            }
            NXNativeDisclaimer()
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button(queueTitle) {
                    for job in viewModel.jobsToQueue() {
                        onAdd(job.sourcePath, job.title)
                    }
                    dismiss()
                }
                .disabled(!viewModel.canQueue)
            }
        }
    }

    private var foundSection: some View {
        Section {
            ForEach(viewModel.games) { game in
                DetectedGameRow(
                    game: game,
                    isSelectable: viewModel.isChoosingAmongGames,
                    isSelected: viewModel.selectedIDs.contains(game.id)
                ) { viewModel.toggle(game) }
            }
            if viewModel.isChoosingAmongGames {
                Button("Select All") { viewModel.selectAll() }
            } else {
                TextField("Real title (used to name the app)", text: $viewModel.name)
            }
            ForEach(viewModel.notes, id: \.self) { note in
                Text(note).font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
            }
        } header: {
            Text(viewModel.isChoosingAmongGames
                ? "\(viewModel.games.count) games in this folder — choose which to build"
                : "Found")
        }
    }

    private var queueTitle: String {
        let count = viewModel.selectedIDs.count
        return count > 1 ? "Add \(count) to Queue" : "Add to Queue"
    }
}

#Preview {
    AddBuildJobSheet(viewModel: AddBuildViewModel(files: InMemoryFileOperations())) { _, _ in }
}
