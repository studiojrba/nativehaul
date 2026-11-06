import Foundation
import Observation

/// Editing a single series: order basis, entries, and its Up Next strip.
@MainActor
@Observable
final class SeriesDetailViewModel {
    /// The series.
    let series: Series
    /// Last error.
    private(set) var errorMessage: String?

    private let repository: any LibraryRepository

    /// Creates the view model.
    init(series: Series, repository: any LibraryRepository) {
        self.series = series
        self.repository = repository
    }

    /// Entries in recommended order.
    var entries: [SeriesEntry] {
        series.orderedEntries
    }

    /// Remaining items, completed dropped, labels untouched.
    var upNext: [UpNextItem] {
        UpNextEngine.upNext(for: series)
    }

    /// Name (saved on change).
    var name: String {
        get { series.name }
        set { perform { series.name = newValue } }
    }

    /// Basis for the recommended order (saved on change).
    var orderBasis: SeriesOrderBasis {
        get { series.orderBasis }
        set { perform { series.orderBasis = newValue } }
    }

    /// Notes explaining the order (saved on change).
    var notes: String {
        get { series.notes }
        set { perform { series.notes = newValue } }
    }

    /// Games and sub-games not yet in this series.
    func candidates() -> [SeriesEntryCandidate] {
        let linked = Set(series.entries.compactMap { $0.game?.id ?? $0.subGame?.id })
        let games = ((try? repository.fetchGames()) ?? []).map(SeriesEntryCandidate.game)
        let subGames = ((try? repository.fetchCollections()) ?? []).flatMap(\.orderedSubGames)
            .map(SeriesEntryCandidate.subGame)
        return (games + subGames).filter { !linked.contains($0.id) }
    }

    /// Appends an entry with the series' own part label.
    func addEntry(_ candidate: SeriesEntryCandidate, partLabel: String) {
        let label = partLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !label.isEmpty else { return }
        perform {
            let entry = SeriesEntry(
                partLabel: label,
                position: OrderedPositions.nextPosition(after: series.entries.map(\.position))
            )
            repository.insert(entry)
            switch candidate {
            case let .game(game): entry.game = game
            case let .subGame(subGame): entry.subGame = subGame
            }
            entry.series = series
        }
    }

    /// Changes the recommended order. Part labels are never changed.
    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        perform {
            let reordered = OrderedPositions.moved(entries, fromOffsets: source, toOffset: destination)
            OrderedPositions.renumber(reordered) { $0.position = $1 }
        }
    }

    /// Removes entries at offsets in the current order.
    func remove(atOffsets offsets: IndexSet) {
        let current = entries
        perform { offsets.map { current[$0] }.forEach(repository.delete) }
    }

    private func perform(_ change: () -> Void) {
        change()
        do {
            try repository.save()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
