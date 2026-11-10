import Foundation
@testable import NXShelf
import Testing

@MainActor
struct LibraryTransferServiceTests {
    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func roundTripPreservesEverything() throws {
        let source = try MockLibraryRepository(seeded: true)
        let data = try LibraryTransferService(repository: source, now: { fixedDate }).exportData()

        let destination = try MockLibraryRepository()
        let summary = try LibraryTransferService(repository: destination).importData(data)

        #expect(summary.gamesAdded == 3)
        #expect(summary.seriesAdded == 1)
        #expect(summary.collectionsAdded == 1)
        let reexported = try LibraryTransferService(repository: destination, now: { fixedDate }).exportData()
        let decoder = LibraryArchiveCoding.makeDecoder()
        #expect(try decoder.decode(LibraryArchive.self, from: data) == decoder.decode(
            LibraryArchive.self,
            from: reexported
        ))
    }

    @Test func importSkipsExistingIdentifiers() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let service = LibraryTransferService(repository: repository)
        let summary = try service.importData(service.exportData())
        #expect(summary.gamesAdded == 0)
        #expect(summary.gamesSkipped == 3)
        #expect(try repository.fetchGames().count == 3)
    }

    @Test func rejectsNewerFormat() throws {
        let archive = LibraryArchive(formatVersion: 99, exportedAt: fixedDate, games: [], series: [], collections: [])
        let data = try LibraryArchiveCoding.makeEncoder().encode(archive)
        let service = try LibraryTransferService(repository: MockLibraryRepository())
        #expect(throws: LibraryTransferError.unsupportedFormatVersion(99)) {
            try service.importData(data)
        }
    }

    @Test func seriesLinksSurviveRoundTrip() throws {
        let source = try MockLibraryRepository(seeded: true)
        let data = try LibraryTransferService(repository: source).exportData()
        let destination = try MockLibraryRepository()
        _ = try LibraryTransferService(repository: destination).importData(data)
        let series = try #require(try destination.fetchSeries().first)
        #expect(series.orderedEntries.map(\.partLabel) == ["1", "2", "3", "4"])
        #expect(series.orderedEntries.first?.subGame?.title == "Lantern I")
        #expect(series.orderedEntries.last?.game?.title == "Tideborn")
    }
}
