import SwiftUI

/// Collections sidebar screen.
struct CollectionsListView: View {
    @State private var viewModel: CollectionsViewModel
    @State private var isAdding = false
    @Environment(AppEnvironment.self) private var environment

    /// Creates the view.
    init(viewModel: CollectionsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            if viewModel.collections.isEmpty {
                ContentUnavailableView(
                    "No Collections",
                    systemImage: "square.stack.3d.up",
                    description: Text("Group compilations and their contained games.")
                )
            }
            ForEach(viewModel.collections) { collection in
                NavigationLink {
                    CollectionDetailView(viewModel: environment.makeCollectionDetailViewModel(for: collection))
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                        Text(collection.name).font(DesignTokens.Typography.headline)
                        Text("\(collection.subGames.count) games").foregroundStyle(Theme.secondaryText)
                    }
                }
                .contextMenu { Button("Delete Collection", role: .destructive) { viewModel.delete(collection) } }
            }
        }
        .navigationTitle("Collections")
        .toolbar { Button("New Collection", systemImage: "plus") { isAdding = true } }
        .onAppear { viewModel.reload() }
        .sheet(isPresented: $isAdding) {
            NameEntrySheet(title: "New Collection") { viewModel.addCollection(name: $0) }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    NavigationStack { CollectionsListView(viewModel: environment.makeCollectionsViewModel()) }
        .environment(environment)
}
