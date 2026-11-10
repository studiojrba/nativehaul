import Foundation
@testable import nativehaul
import Testing

struct StatsCalculatorTests {
    typealias Fix = StatsFixtures

    @Test func emptyLibrary() {
        let stats = StatsCalculator.stats(for: .empty)
        #expect(stats.totalGames == 0)
        #expect(stats.completionFraction == 0)
        #expect(stats.secondsBySource.isEmpty)
    }

    @Test func countsHoursAndCompletion() {
        let snapshot = LibrarySnapshot(games: [
            Fix.game("A", status: .completed, sessions: [Fix.session(dayOffset: 0, hours: 2)]),
            Fix.game("B", status: .backlog, selfReported: Fix.hour),
            Fix.game("C", status: .backlog),
            Fix.game("D", status: .playing, sessions: [Fix.session(dayOffset: 1, hours: 1, source: .selfReported)]),
        ], seriesEntryStatuses: [], collectionStatuses: [])
        let stats = StatsCalculator.stats(for: snapshot)
        #expect(stats.totalGames == 4)
        #expect(stats.count(.backlog) == 2)
        #expect(stats.count(.abandoned) == 0)
        #expect(stats.completionFraction == 0.25)
        #expect(stats.secondsBySource[.macTracked] == 2 * Fix.hour)
        #expect(stats.secondsBySource[.selfReported] == 2 * Fix.hour)
        #expect(stats.secondsBySource[.hltbEstimate] == nil)
    }

    @Test func estimatesNeverCounted() {
        let snapshot = LibrarySnapshot(games: [
            Fix.game("A", sessions: [Fix.session(dayOffset: 0, hours: 50, source: .hltbEstimate)]),
        ], seriesEntryStatuses: [], collectionStatuses: [])
        #expect(StatsCalculator.stats(for: snapshot).secondsBySource.isEmpty)
    }

    @Test @MainActor func viewModelFormatsCompletion() {
        let provider = MockSnapshotProvider(LibrarySnapshot(
            games: [Fix.game("A", status: .completed), Fix.game("B"), Fix.game("C")],
            seriesEntryStatuses: [], collectionStatuses: []
        ))
        let viewModel = StatsViewModel(provider: provider)
        viewModel.reload()
        #expect(viewModel.completionText.hasPrefix("33"))
        #expect(viewModel.earnedCount == 1)
        #expect(viewModel.badges.count == BadgeCatalog.all.count)
    }

    @Test @MainActor func repositorySnapshotMatchesSeed() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let snapshot = try RepositorySnapshotProvider(repository: repository).snapshot()
        #expect(snapshot.games.count == 3)
        #expect(snapshot.seriesEntryStatuses == [[.completed, .backlog, .backlog, .backlog]])
        #expect(snapshot.collectionStatuses == [[.completed, .backlog, .backlog]])
    }
}
