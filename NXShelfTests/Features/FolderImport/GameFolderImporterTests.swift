import Foundation
@testable import NXShelf
import Testing

/// The 1.0 headline (ADR 0046): first run and every rescan adopt what is already on disk, with zero rebuilding:
/// existing nxnative builds (by folder, port library or the title ID stamped in their bundle) and ROM folders.
@MainActor
struct GameFolderImporterTests {
    private static let switchFolder = "/Users/demo/Switch/Games"
    private static let macFolder = "/Users/demo/Games"

    private static let tideborn = DiscoveredApp(name: "Tideborn", path: "\(switchFolder)/Tideborn.app")
    private static let moonwell = DiscoveredApp(
        name: "moonwell_build",
        path: "\(switchFolder)/Moonwell.app",
        title: "Moonwell"
    )
    private static let glimmer = DiscoveredApp(name: "Glimmer", path: "\(macFolder)/Glimmer.app")
    private static let ported = DiscoveredApp(
        name: "Ported", path: "\(macFolder)/Ports/Ported.app", hasPortLibrarySibling: true
    )
    private static let stamped = DiscoveredApp(
        name: "Super Mario Odyssey",
        path: "\(macFolder)/Elsewhere/Super Mario Odyssey.app",
        switchTitleID: "0100000000010000"
    )
    private static let rom = DiscoveredRom(
        path: "\(macFolder)/ROMs/Lantern Coast.gba", title: "Lantern Coast", system: .gameBoyAdvance
    )

    private func makeImporter(
        repository: MockLibraryRepository,
        folders: [String] = [switchFolder, macFolder],
        roms: [DiscoveredRom] = [rom],
        watcher: MockPlaytimeWatcher = MockPlaytimeWatcher()
    ) -> GameFolderImporter {
        let scanner = MockAppBundleScanner(apps: [], appsByFolder: [
            Self.switchFolder: [Self.tideborn, Self.moonwell],
            Self.macFolder: [Self.glimmer, Self.ported, Self.stamped],
        ])
        return GameFolderImporter(
            folders: InMemoryGameFolderStore(folders),
            discoverer: GameFolderDiscoverer(
                scanner: scanner,
                folderExists: { $0 != "/missing" },
                romScanner: MockRomScanner(romsByFolder: [Self.macFolder: roms])
            ),
            repository: repository,
            trackingPreferences: InMemoryTrackingPreferencesStore(TrackingPreferences(gamesFolder: Self.switchFolder)),
            watcher: watcher
        )
    }

    @Test func existingBuildsAndROMsAreAdoptedWithTheirPlatforms() async throws {
        let repository = try MockLibraryRepository()
        let watcher = MockPlaytimeWatcher()
        let summary = try await makeImporter(repository: repository, watcher: watcher).scanConfiguredFolders()

        let games = try repository.fetchGames()
        let byTitle = Dictionary(uniqueKeysWithValues: games.map { ($0.title, $0) })
        #expect(byTitle["Tideborn"]?.platform == .switchPort)
        #expect(byTitle["Moonwell"]?.platform == .switchPort)
        #expect(byTitle["Moonwell"]?.appBundlePath == BundlePath.normalize(Self.moonwell.path))
        #expect(byTitle["Glimmer"]?.platform == .macNative)
        #expect(byTitle["Ported"]?.platform == .switchPort)
        #expect(byTitle["Super Mario Odyssey"]?.platform == .switchPort)
        #expect(byTitle["Super Mario Odyssey"]?.switchTitleID == "0100000000010000")
        #expect(byTitle["Lantern Coast"]?.platform == .emulated)
        #expect(byTitle["Lantern Coast"]?.emulatedSystem == .gameBoyAdvance)
        #expect(games.allSatisfy { $0.status == .backlog })
        #expect(summary == FolderImportSummary(found: 6, added: 5, romsAdded: 1))
        #expect(watcher.refreshCount == 1)
    }

    @Test func rescanIsIdempotent() async throws {
        let repository = try MockLibraryRepository()
        let importer = makeImporter(repository: repository)
        _ = try await importer.scanConfiguredFolders()
        let countAfterFirst = try repository.fetchGames().count
        let second = try await importer.scanConfiguredFolders()
        #expect(second.added == 0)
        #expect(second.romsAdded == 0)
        #expect(second.linked == 0)
        #expect(try repository.fetchGames().count == countAfterFirst)
    }

    @Test func aRescanAdoptsTheStampedTitleIDOfAnAlreadyKnownApp() async throws {
        let repository = try MockLibraryRepository()
        let known = Game(title: "Super Mario Odyssey", platform: .macNative)
        known.appBundlePath = BundlePath.normalize(Self.stamped.path)
        repository.insert(known)
        try repository.save()
        _ = try await makeImporter(repository: repository, roms: []).scanConfiguredFolders()
        #expect(known.switchTitleID == "0100000000010000")
        #expect(known.platform == .switchPort)
    }

    @Test func aTitleIDFromABuildThroughNXShelfIsNeverOverwritten() async throws {
        let repository = try MockLibraryRepository()
        let built = Game(title: "Super Mario Odyssey", platform: .switchPort)
        built.appBundlePath = BundlePath.normalize(Self.stamped.path)
        built.switchTitleID = "0100000000010800"
        repository.insert(built)
        try repository.save()
        _ = try await makeImporter(repository: repository, roms: []).scanConfiguredFolders()
        #expect(built.switchTitleID == "0100000000010800")
    }

    @Test func linksExistingGameWithoutBundlePathByNormalizedTitle() async throws {
        let repository = try MockLibraryRepository()
        let logbookEntry = Game(title: "TIDEBORN!", platform: .switchPort, status: .playing)
        let alreadyTracked = Game(title: "Glimmer", platform: .macNative)
        alreadyTracked.appBundlePath = "/elsewhere/Glimmer.app"
        repository.insert(logbookEntry)
        repository.insert(alreadyTracked)
        try repository.save()

        let summary = try await makeImporter(repository: repository, roms: []).scanConfiguredFolders()

        #expect(logbookEntry.appBundlePath == BundlePath.normalize(Self.tideborn.path))
        #expect(logbookEntry.status == .playing)
        #expect(summary.linked == 1)
        let games = try repository.fetchGames()
        #expect(games.count { TitleNormalizer.matches($0.title, "Tideborn") } == 1)
        // A game that already has a different bundle path is not re-linked; the new bundle becomes its own entry.
        #expect(games.count { $0.title == "Glimmer" } == 2)
    }

    @Test func reportsUnreadableFolders() async throws {
        let repository = try MockLibraryRepository()
        let summary = try await makeImporter(repository: repository, folders: ["/missing"], roms: [])
            .scanConfiguredFolders()
        #expect(summary.unreadableFolders == ["/missing"])
        #expect(summary.description.contains("Could not read: /missing"))
    }
}
