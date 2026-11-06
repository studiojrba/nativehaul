import Foundation
@testable import Playrite
import Testing

@MainActor
struct LibraryDeduplicatorTests {
    private static let bundle = "/Users/demo/Switch/Games/Tideborn.app"

    /// J.R's case: a folder-scanned entry (tracked bundle + Mac sessions) and an imported entry
    /// (status, hours, description, series, guide, HLTB id) for the same Switch port.
    private func makeScenario() throws -> (MockLibraryRepository, scanned: Game, imported: Game, series: Series) {
        let repository = try MockLibraryRepository()
        let scanned = Game(title: "Tideborn", platform: .switchPort, addedAt: Date(timeIntervalSince1970: 100))
        scanned.appBundlePath = Self.bundle
        let imported = Game(
            title: "Tideborn™", platform: .switchPort, status: .playing,
            summary: "Sea-faring roguelite.", addedAt: Date(timeIntervalSince1970: 200)
        )
        imported.selfReportedSeconds = 36000
        imported.hltbID = 4242
        let session = PlaySession(
            startedAt: Date(timeIntervalSince1970: 1000), endedAt: Date(timeIntervalSince1970: 4600),
            source: .macTracked
        )
        let guide = GuideLink(title: "Walkthrough", author: "Ana", url: "https://gamefaqs.gamespot.com/x/faqs/1")
        let series = Series(name: "Tide Saga")
        let entry = SeriesEntry(partLabel: "1", position: 0)
        for model in [scanned, imported] as [Game] {
            repository.insert(model)
        }
        repository.insert(session)
        repository.insert(guide)
        repository.insert(series)
        repository.insert(entry)
        session.game = scanned
        guide.game = imported
        entry.game = imported
        entry.series = series
        try repository.save()
        return (repository, scanned, imported, series)
    }

    @Test func previewsWithoutChanging() throws {
        let (repository, scanned, imported, _) = try makeScenario()
        let groups = try LibraryDeduplicator(repository: repository).findDuplicates()
        #expect(groups.count == 1)
        #expect(groups.first?.survivorID == imported.id)
        #expect(groups.first?.duplicateIDs == [scanned.id])
        #expect(groups.first?.gains == ["tracked app", "1 session"])
        #expect(try repository.fetchGames().count == 2)
    }

    @Test func mergesIntoImportedEntryAndDeletesDuplicate() throws {
        let (repository, _, imported, series) = try makeScenario()
        let deleted = try LibraryDeduplicator(repository: repository).mergeAll()

        #expect(deleted == 1)
        let games = try repository.fetchGames()
        #expect(games.count == 1)
        let survivor = try #require(games.first)
        #expect(survivor.id == imported.id)
        #expect(survivor.title == "Tideborn™")
        #expect(survivor.appBundlePath == Self.bundle)
        #expect(survivor.sessions.count == 1)
        #expect(survivor.sessions.first?.source == .macTracked)
        #expect(survivor.status == .playing)
        #expect(survivor.selfReportedSeconds == 36000)
        #expect(survivor.summary == "Sea-faring roguelite.")
        #expect(survivor.hltbID == 4242)
        #expect(survivor.guides.count == 1)
        #expect(survivor.addedAt == Date(timeIntervalSince1970: 100))
        #expect(series.entries.first?.game?.id == imported.id)
        #expect(try LibraryDeduplicator(repository: repository).findDuplicates().isEmpty)
    }

    @Test func neverMergesTwoDifferentBuildsOrSteamApps() throws {
        let repository = try MockLibraryRepository()
        let first = Game(title: "Moonwell")
        first.appBundlePath = "/a/Moonwell.app"
        let second = Game(title: "moonwell")
        second.appBundlePath = "/b/Moonwell.app"
        let steamA = Game(title: "Glimmer")
        steamA.steamAppID = 1
        let steamB = Game(title: "Glimmer")
        steamB.steamAppID = 2
        for game in [first, second, steamA, steamB] {
            repository.insert(game)
        }
        try repository.save()
        #expect(try LibraryDeduplicator(repository: repository).findDuplicates().isEmpty)
    }

    @Test func movesHLTBEstimateToSurvivor() throws {
        let (repository, scanned, imported, _) = try makeScenario()
        let hltb = CachedHLTBService(cache: InMemoryHLTBCache())
        try hltb.saveManual(gameID: scanned.id, title: "Tideborn", seconds: [.mainStory: 7200])
        let scannedID = scanned.id
        try LibraryDeduplicator(repository: repository, hltb: hltb).mergeAll()
        #expect(hltb.cachedEstimate(for: imported.id)?.seconds[.mainStory] == 7200)
        #expect(hltb.cachedEstimate(for: scannedID) == nil)
    }

    @Test func libraryImportMergesWithScannedEntry() throws {
        let source = try MockLibraryRepository()
        let record = Game(title: "Tideborn", platform: .switchPort, status: .completed)
        record.hltbID = 7
        source.insert(record)
        try source.save()
        let data = try LibraryTransferService(repository: source).exportData()

        let destination = try MockLibraryRepository()
        let scanned = Game(title: "TIDEBORN", platform: .switchPort)
        scanned.appBundlePath = Self.bundle
        destination.insert(scanned)
        try destination.save()

        let summary = try LibraryTransferService(
            repository: destination,
            deduplicator: LibraryDeduplicator(repository: destination)
        ).importData(data)

        #expect(summary.duplicatesMerged == 1)
        let games = try destination.fetchGames()
        #expect(games.count == 1)
        #expect(games.first?.id == record.id)
        #expect(games.first?.status == .completed)
        #expect(games.first?.hltbID == 7)
        #expect(games.first?.appBundlePath == Self.bundle)
    }

    @Test func viewModelPreviewsThenMerges() {
        let mock = MockLibraryDeduplicator()
        var changed = 0
        let viewModel = MergeDuplicatesViewModel(deduplicator: mock) { changed += 1 }
        viewModel.refresh()
        #expect(viewModel.pendingDeletions == 1)
        viewModel.mergeAll()
        #expect(viewModel.deletedCount == 1)
        #expect(viewModel.groups.isEmpty)
        #expect(changed == 1)
    }
}
