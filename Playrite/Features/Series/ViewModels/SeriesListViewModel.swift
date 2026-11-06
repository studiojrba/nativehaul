import Foundation
import Observation

/// Series sidebar screen.
@MainActor
@Observable
final class SeriesListViewModel {
    /// All series, sorted by name.
    private(set) var series: [Series] = []
    /// Last error.
    private(set) var errorMessage: String?

    private let repository: any LibraryRepository

    /// Creates the view model.
    init(repository: any LibraryRepository) {
        self.repository = repository
    }

    /// Reloads series.
    func reload() {
        perform {}
    }

    /// Adds a series. Blank names are ignored.
    func addSeries(name: String, orderBasis: SeriesOrderBasis) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        perform { repository.insert(Series(name: trimmed, orderBasis: orderBasis)) }
    }

    /// Deletes a series and its entries (linked games are untouched).
    func delete(_ series: Series) {
        perform { repository.delete(series) }
    }

    /// Remaining items for a series.
    func upNext(for series: Series) -> [UpNextItem] {
        UpNextEngine.upNext(for: series)
    }

    private func perform(_ change: () -> Void) {
        change()
        do {
            try repository.save()
            series = try repository.fetchSeries()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
