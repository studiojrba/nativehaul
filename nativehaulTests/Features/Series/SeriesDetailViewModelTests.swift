import Foundation
@testable import nativehaul
import Testing

@MainActor
struct SeriesDetailViewModelTests {
    @Test func reorderNeverRenumbersPartLabels() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let series = try #require(try repository.fetchSeries().first)
        let viewModel = SeriesDetailViewModel(series: series, repository: repository)
        #expect(viewModel.entries.map(\.partLabel) == ["1", "2", "3", "4"])
        viewModel.move(fromOffsets: IndexSet(integer: 3), toOffset: 0)
        #expect(viewModel.entries.map(\.partLabel) == ["4", "1", "2", "3"])
        #expect(viewModel.entries.map(\.position) == [0, 1, 2, 3])
        #expect(viewModel.upNext.map(\.partLabel) == ["4", "2", "3"])
    }

    @Test func addEntryAppendsAndExcludesFromCandidates() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let series = try #require(try repository.fetchSeries().first)
        let viewModel = SeriesDetailViewModel(series: series, repository: repository)
        let candidate = try #require(viewModel.candidates().first { $0.title == "Ember Protocol" })
        viewModel.addEntry(candidate, partLabel: " 5 ")
        viewModel.addEntry(candidate, partLabel: "   ")
        #expect(viewModel.entries.last?.partLabel == "5")
        #expect(viewModel.entries.count == 5)
        #expect(!viewModel.candidates().contains(candidate))
    }

    @Test func removeEntry() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let series = try #require(try repository.fetchSeries().first)
        let viewModel = SeriesDetailViewModel(series: series, repository: repository)
        viewModel.remove(atOffsets: IndexSet(integer: 0))
        #expect(viewModel.entries.map(\.partLabel) == ["2", "3", "4"])
    }

    @Test func basisIsStored() throws {
        let repository = try MockLibraryRepository()
        let series = Series(name: "S")
        repository.insert(series)
        let viewModel = SeriesDetailViewModel(series: series, repository: repository)
        viewModel.orderBasis = .chronological
        #expect(series.orderBasis == .chronological)
    }

    @Test func membershipViaCollectionParent() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let parent = try #require(try repository.fetchGames().first { $0.title == "Ember Protocol" })
        let viewModel = SeriesMembershipViewModel(game: parent, repository: repository)
        #expect(viewModel.memberships.map(\.series.name) == ["Lantern Saga"])
    }

    @Test func seriesListAddAndDelete() throws {
        let repository = try MockLibraryRepository()
        let viewModel = SeriesListViewModel(repository: repository)
        viewModel.addSeries(name: "  ", orderBasis: .release)
        viewModel.addSeries(name: "Saga", orderBasis: .chronological)
        #expect(viewModel.series.map(\.name) == ["Saga"])
        try viewModel.delete(#require(viewModel.series.first))
        #expect(viewModel.series.isEmpty)
    }
}
