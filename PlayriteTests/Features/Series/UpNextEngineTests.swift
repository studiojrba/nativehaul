import Foundation
@testable import Playrite
import Testing

@MainActor
struct UpNextEngineTests {
    /// Builds a series whose entries are inserted out of order to prove ordering uses `position`.
    private func makeSeries(
        _ repository: MockLibraryRepository,
        statuses: [(label: String, position: Int, status: GameStatus?)]
    ) -> Series {
        let series = Series(name: "Saga", orderBasis: .chronological)
        repository.insert(series)
        for spec in statuses {
            let entry = SeriesEntry(partLabel: spec.label, position: spec.position)
            repository.insert(entry)
            if let status = spec.status {
                let game = Game(title: "Game \(spec.label)", status: status)
                repository.insert(game)
                entry.game = game
            }
            entry.series = series
        }
        return series
    }

    @Test func dropsCompletedKeepsTrueOrderAndLabels() throws {
        let repository = try MockLibraryRepository()
        let series = makeSeries(repository, statuses: [
            ("3", 0, .backlog), // chronological: part 3 is played first
            ("1", 1, .completed),
            ("Zero", 2, .playing),
            ("2", 3, nil),
        ])
        let items = UpNextEngine.upNext(for: series)
        #expect(items.map(\.partLabel) == ["3", "Zero", "2"])
        #expect(items.map(\.isNext) == [true, false, false])
        #expect(items.last?.status == nil)
        #expect(items.last?.title == "Part 2")
    }

    @Test func allCompletedIsEmpty() throws {
        let repository = try MockLibraryRepository()
        let series = makeSeries(repository, statuses: [("1", 0, .completed), ("2", 1, .completed)])
        #expect(UpNextEngine.upNext(for: series).isEmpty)
        #expect(UpNextEngine.completionFraction(for: series) == 1)
    }

    @Test func completionFraction() throws {
        let repository = try MockLibraryRepository()
        let series = makeSeries(
            repository,
            statuses: [("1", 0, .completed), ("2", 1, .backlog), ("3", 2, nil), ("4", 3, .abandoned)]
        )
        #expect(UpNextEngine.completionFraction(for: series) == 0.25)
        #expect(UpNextEngine.completionFraction(for: Series(name: "Empty")) == 0)
    }

    @Test func subGameStatusDrivesUpNext() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let series = try #require(try repository.fetchSeries().first)
        // Seed: Lantern I completed (sub-game), II and III backlog, finale Tideborn backlog.
        let items = UpNextEngine.upNext(for: series)
        #expect(items.map(\.partLabel) == ["2", "3", "4"])
        #expect(items.first?.title == "Lantern II")
    }
}
