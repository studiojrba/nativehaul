import Foundation
@testable import NXShelf
import Testing

@MainActor
struct GameInfoBuilderTests {
    @Test func rowsCoverEveryRequestedFieldInOrder() {
        let game = Game(
            title: "Super Mario Odyssey",
            platform: .switchPort,
            status: .playing,
            releaseDate: Date(timeIntervalSince1970: 0)
        )
        game.developer = "Nintendo"
        game.tags = ["Puzzle", "Co-op"]
        game.installSizeBytes = 12_000_000_000
        game.appBundlePath = "/Users/demo/Switch/Games/Super Mario Odyssey.app"
        game.selfReportedSeconds = 7200
        let session = PlaySession(
            startedAt: .distantPast,
            endedAt: .distantPast.addingTimeInterval(36000),
            source: .macTracked
        )
        game.sessions = [session]

        let rows = GameInfoBuilder.rows(for: game)
        #expect(rows.map(\.label) == [
            "Status", "Install Size", "Time Played", "Developer", "Source",
            "Release Date", "Date Added", "Platform", "Tags",
        ])
        let values = Dictionary(uniqueKeysWithValues: rows.map { ($0.label, $0.value) })
        #expect(values["Status"] == "Playing")
        #expect(values["Developer"] == "Nintendo")
        #expect(values["Source"] == "Local app")
        #expect(values["Tags"] == "Puzzle, Co-op")
        #expect(values["Install Size"] != GameInfoBuilder.unknown)
        // Never a merged total: each source appears with its own label.
        let played = values["Time Played"] ?? ""
        #expect(played.contains(PlaytimeSource.macTracked.label))
        #expect(played.contains(PlaytimeSource.selfReported.label))
    }

    @Test func unknownsAndCaption() {
        let game = Game(title: "Logbook", platform: .switchPort)
        let values = Dictionary(uniqueKeysWithValues: GameInfoBuilder.rows(for: game).map { ($0.label, $0.value) })
        #expect(values["Time Played"] == "Not played")
        #expect(values["Developer"] == GameInfoBuilder.unknown)
        #expect(values["Source"] == "Library entry")
        #expect(GameInfoBuilder.gridCaption(for: game) == "Switch (native port)")
        game.appBundlePath = "/Games/Logbook.app"
        #expect(GameInfoBuilder.source(game) == "Local app")
    }

    @Test func hltbChipsUseRequestedNames() {
        #expect(HLTBChip.chips(for: nil).map(\.title) == ["Main Story", "Main Story+", "Completionist"])
        #expect(HLTBChip.chips(for: nil).allSatisfy { $0.value == "—" })
    }

    @Test func mergeCarriesMetadataAndProvenance() {
        let survivor = Game(title: "Portal 2", status: .playing, summary: "Imported")
        survivor.genres = ["Puzzle"]
        let duplicate = Game(title: "Portal 2")
        duplicate.genres = ["puzzle", "Co-op"]
        duplicate.developer = "Valve"
        duplicate.romPath = "/roms/Portal 2.iso"
        GameMerger.merge(duplicate, into: survivor)
        #expect(survivor.genres == ["Puzzle", "Co-op"])
        #expect(survivor.developer == "Valve")
        #expect(survivor.romPath == "/roms/Portal 2.iso")
    }

    @Test func archiveRoundTripsMetadata() throws {
        let source = try MockLibraryRepository()
        let game = Game(title: "Tideborn")
        game.developer = "Studio"
        game.genres = ["Roguelite"]
        game.tags = ["Favourite"]
        game.heroImagePath = "/art/hero.png"
        source.insert(game)
        try source.save()
        let data = try LibraryTransferService(repository: source).exportData()
        let destination = try MockLibraryRepository()
        _ = try LibraryTransferService(repository: destination).importData(data)
        let copy = try #require(try destination.fetchGames().first)
        #expect(copy.developer == "Studio")
        #expect(copy.genres == ["Roguelite"])
        #expect(copy.tags == ["Favourite"])
        #expect(copy.heroImagePath == "/art/hero.png")
    }

    @Test func bundleSizesApplyOnScan() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("NXShelfSize-\(UUID().uuidString)")
        let bundle = root.appendingPathComponent("Sized.app/Contents/MacOS")
        try FileManager.default.createDirectory(at: bundle, withIntermediateDirectories: true)
        try Data(repeating: 1, count: 10000).write(to: bundle.appendingPathComponent("Sized"))
        defer { try? FileManager.default.removeItem(at: root) }
        let size = try #require(BundleSizeCalculator.size(ofBundleAt: root.appendingPathComponent("Sized.app").path))
        #expect(size >= 10000)
    }
}
