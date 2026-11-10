import Foundation
@testable import nativehaul
import Testing

@MainActor
struct HLTBIntegrationTests {
    @Test func detailBreakdownShowsEstimateAsSeparateLabelledRow() throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "Tideborn")
        game.selfReportedSeconds = 3600
        repository.insert(game)
        let hltb = CachedHLTBService(cache: InMemoryHLTBCache())
        try hltb.saveManual(gameID: game.id, title: game.title, seconds: [.mainStory: 36000])
        let breakdown = GameDetailViewModel(game: game, repository: repository, hltb: hltb).breakdown
        #expect(breakdown.seconds(for: .hltbEstimate) == 36000)
        #expect(breakdown.seconds(for: .selfReported) == 3600)
        #expect(breakdown.entries.first { $0.source == .hltbEstimate }?.source.label == "HLTB estimate")
    }

    @Test func backlogEstimateIsSeparateFromRealHours() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let hltb = CachedHLTBService(cache: InMemoryHLTBCache())
        for game in try repository.fetchGames() {
            try hltb.saveManual(gameID: game.id, title: game.title, seconds: [.mainStory: 10 * 3600])
        }
        let viewModel = StatsViewModel(provider: RepositorySnapshotProvider(repository: repository), hltb: hltb)
        viewModel.reload()
        #expect(viewModel.backlogEstimate == HLTBBacklogEstimate(seconds: 36000, coveredGames: 1, backlogGames: 1))
        #expect(viewModel.stats.secondsBySource[.hltbEstimate] == nil)
        #expect(!viewModel.hoursBySource.contains { $0.source == .hltbEstimate })
    }

    @Test func hltbViewModelOpensSearchAndSaves() {
        let opener = RecordingURLOpener()
        let game = Game(title: "Tideborn")
        let viewModel = HLTBViewModel(
            game: game,
            service: CachedHLTBService(cache: InMemoryHLTBCache()),
            opener: opener
        )
        viewModel.openSearch()
        #expect(opener.opened.first?.host() == "howlongtobeat.com")
        viewModel.saveManual(hours: [.mainStory: 12.5])
        #expect(viewModel.rows.map(\.text) == ["12h 30m · HLTB estimate"])
    }
}
