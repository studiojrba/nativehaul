import SwiftUI

/// Edit a collection's ordered sub-games and their individual statuses.
struct CollectionDetailView: View {
    @State private var viewModel: CollectionDetailViewModel
    @State private var newTitle = ""

    /// Creates the view.
    init(viewModel: CollectionDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                Picker("Library entry", selection: $viewModel.parentGameID) {
                    Text("None").tag(UUID?.none)
                    ForEach(viewModel.parentCandidates) { Text($0.title).tag(Optional($0.id)) }
                }
            }
            Section("Games in this collection") {
                ForEach(viewModel.subGames) { subGame in
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Text(subGame.title)
                        Spacer(minLength: DesignTokens.Spacing.none)
                        Picker("Status", selection: Binding(
                            get: { subGame.status },
                            set: { viewModel.setStatus($0, for: subGame) }
                        )) {
                            ForEach(GameStatus.allCases) { Text($0.displayName).tag($0) }
                        }
                        .labelsHidden()
                        .fixedSize()
                    }
                }
                .onMove { viewModel.move(fromOffsets: $0, toOffset: $1) }
                .onDelete { viewModel.remove(atOffsets: $0) }
                HStack(spacing: DesignTokens.Spacing.md) {
                    TextField("Add a game…", text: $newTitle)
                        .onSubmit(add)
                    Button("Add", action: add).disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(Theme.danger)
            }
        }
        .navigationTitle(viewModel.collection.name)
    }

    private func add() {
        viewModel.addSubGame(title: newTitle)
        newTitle = ""
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let collection = try? environment.repository.fetchCollections().first {
        NavigationStack { CollectionDetailView(viewModel: environment.makeCollectionDetailViewModel(for: collection)) }
    }
}
