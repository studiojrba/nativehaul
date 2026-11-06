import SwiftUI

/// Edit a series: order basis, recommended order, Up Next.
struct SeriesDetailView: View {
    @State private var viewModel: SeriesDetailViewModel
    @State private var isAddingEntry = false

    /// Creates the view.
    init(viewModel: SeriesDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                TextField("Name", text: $viewModel.name)
                Picker("Recommended order", selection: $viewModel.orderBasis) {
                    ForEach(SeriesOrderBasis.allCases) { Text($0.displayName).tag($0) }
                }
                TextField("Why this order?", text: $viewModel.notes, axis: .vertical)
            }
            Section {
                UpNextStrip(title: "Up Next", items: viewModel.upNext)
            }
            Section("Recommended Order (\(viewModel.orderBasis.displayName))") {
                ForEach(viewModel.entries) { entry in
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Text("Part \(entry.partLabel)").font(DesignTokens.Typography.captionEmphasis)
                        Text(entry.displayTitle)
                        Spacer(minLength: DesignTokens.Spacing.none)
                        if let status = entry.linkedStatus {
                            StatusTag(status: status)
                        }
                    }
                }
                .onMove { viewModel.move(fromOffsets: $0, toOffset: $1) }
                .onDelete { viewModel.remove(atOffsets: $0) }
            }
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(Theme.danger)
            }
        }
        .navigationTitle(viewModel.name)
        .toolbar { Button("Add Entry", systemImage: "plus") { isAddingEntry = true } }
        .sheet(isPresented: $isAddingEntry) {
            AddSeriesEntrySheet(candidates: viewModel.candidates()) { viewModel.addEntry($0, partLabel: $1) }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let series = try? environment.repository.fetchSeries().first {
        NavigationStack { SeriesDetailView(viewModel: environment.makeSeriesDetailViewModel(for: series)) }
    }
}
