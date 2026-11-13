import Foundation
@testable import nativehaul
import Testing

/// Spec §3.2: the Library's three sort orders.
@MainActor
struct LibrarySortTests {
    @Test func recentlyPlayedPutsTheLatestFirstAndNeverPlayedLast() throws {
        let fixture = try GameFixture()
        let games = [
            fixture.game("Older", endedAgo: 3 * GameFixture.day),
            fixture.game("Never"),
            fixture.game("Latest", endedAgo: GameFixture.hour),
            fixture.game("Also never"),
        ]
        #expect(LibrarySort.recentlyPlayed.apply(to: games).map(\.title) == ["Latest", "Older", "Also never", "Never"])
    }

    @Test func alphabeticalIgnoresALeadingThe() throws {
        let fixture = try GameFixture()
        let games = ["The Zebra", "Apple", "the Mango", "Theatre", "Banana"].map { fixture.game($0) }
        #expect(LibrarySort.alphabetical.apply(to: games).map(\.title)
            == ["Apple", "Banana", "the Mango", "Theatre", "The Zebra"])
    }

    @Test func mostPlayedUsesEachGamesBiggestSourceNeverASum() throws {
        let fixture = try GameFixture()
        let split = fixture.game("Split", endedAgo: GameFixture.day, hours: 6, selfReportedHours: 6)
        let single = fixture.game("Single", selfReportedHours: 10)
        let none = fixture.game("None")
        #expect(split.biggestRealPlaytimeSeconds == DurationFormatting.seconds(hours: 6))
        #expect(LibrarySort.mostPlayed.apply(to: [split, none, single]).map(\.title) == ["Single", "Split", "None"])
    }

    @Test func hltbEstimatesNeverCountAsPlaytime() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Estimate only")
        #expect(game.biggestRealPlaytimeSeconds == 0)
    }

    @Test func labelsMatchTheDesign() {
        #expect(LibrarySort.allCases.map(\.title) == ["Recently played", "A–Z", "Most played"])
    }

    @Test func theLibraryViewModelSortsWhatItShows() throws {
        let fixture = try GameFixture()
        fixture.game("B")
        fixture.game("The A")
        try fixture.repository.save()
        let viewModel = LibraryViewModel(repository: fixture.repository, transfer: MockLibraryTransferService())
        viewModel.reload()
        viewModel.sort = .alphabetical
        #expect(viewModel.shelfGames.map(\.title) == ["The A", "B"])
        #expect(!viewModel.isFiltered)
        viewModel.filter.section = .playing
        #expect(viewModel.isFiltered)
        #expect(viewModel.shelfGames.isEmpty)
        viewModel.clearFilters()
        #expect(viewModel.shelfGames.count == 2)
    }
}
