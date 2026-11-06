import SwiftUI

/// Series sidebar screen: each series with its Up Next strip.
struct SeriesListView: View {
    @State private var viewModel: SeriesListViewModel
    @State private var isAdding = false
    @State private var newBasis: SeriesOrderBasis = .release
    @Environment(AppEnvironment.self) private var environment

    /// Creates the view.
    init(viewModel: SeriesListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            if viewModel.series.isEmpty {
                ContentUnavailableView(
                    "No Series",
                    systemImage: "books.vertical",
                    description: Text("Create a series to plan its play order.")
                )
            }
            ForEach(viewModel.series) { series in
                NavigationLink {
                    SeriesDetailView(viewModel: environment.makeSeriesDetailViewModel(for: series))
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text(series.name).font(DesignTokens.Typography.title)
                        Text(series.orderBasis.displayName).foregroundStyle(Theme.secondaryText)
                        UpNextStrip(title: "Up Next", items: viewModel.upNext(for: series))
                    }
                    .padding(.vertical, DesignTokens.Spacing.sm)
                }
                .contextMenu { Button("Delete Series", role: .destructive) { viewModel.delete(series) } }
            }
        }
        .navigationTitle("Series")
        .toolbar { Button("New Series", systemImage: "plus") { isAdding = true } }
        .onAppear { viewModel.reload() }
        .sheet(isPresented: $isAdding) {
            NameEntrySheet(title: "New Series", extra: basisPicker) {
                viewModel.addSeries(name: $0, orderBasis: newBasis)
            }
        }
    }

    private var basisPicker: some View {
        Picker("Recommended order", selection: $newBasis) {
            ForEach(SeriesOrderBasis.allCases) { Text($0.displayName).tag($0) }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    NavigationStack { SeriesListView(viewModel: environment.makeSeriesListViewModel()) }
        .environment(environment)
}
