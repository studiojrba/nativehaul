import Foundation
@testable import NXShelf
import Testing

@MainActor
struct GameFolderImporterTests {
    private static let switchFolder = "/Users/demo/Switch/Games"
    private static let macFolder = "/Users/demo/Games"
    private static let launchers = "/Users/demo/Applications/CrossOver"
    private static let bottles = "/Users/demo/Bottles"

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
    private static let lanternLauncher = DiscoveredApp(name: "Lanternfall", path: "\(launchers)/Lanternfall.app")

    private static func install(_ name: String) -> CrossOverInstall {
        CrossOverInstall(
            name: name,
            bottle: "Games",
            folderPath: "\(bottles)/Games/drive_c/Program Files/\(name)",
            executablePath: "\(bottles)/Games/drive_c/Program Files/\(name)/\(name).exe"
        )
    }

    private func makeImporter(
        repository: MockLibraryRepository,
        folders: [String] = [switchFolder, macFolder],
        installs: [CrossOverInstall] = [install("Lanternfall"), install("Ashen Road")],
        watcher: MockPlaytimeWatcher = MockPlaytimeWatcher()
    ) -> GameFolderImporter {
        let scanner = MockAppBundleScanner(apps: [], appsByFolder: [
            Self.switchFolder: [Self.tideborn, Self.moonwell],
            Self.macFolder: [Self.glimmer, Self.ported],
            Self.launchers: [Self.lanternLauncher],
        ])
        let locations = CrossOverLocations(bottlesRoot: Self.bottles, launchersFolder: Self.launchers)
        let crossOver = MockCrossOverScanner(result: CrossOverScanResult(
            bottles: ["Games", "Tools"],
            installs: installs
        ))
        return GameFolderImporter(
            folders: InMemoryGameFolderStore(folders),
            discoverer: GameFolderDiscoverer(
                scanner: scanner,
                crossOver: crossOver,
                locations: locations,
                folderExists: { $0 != "/missing" }
            ),
            repository: repository,
            trackingPreferences: InMemoryTrackingPreferencesStore(TrackingPreferences(gamesFolder: Self.switchFolder)),
            watcher: watcher,
            locations: locations
        )
    }

    @Test func importsWithPlatformsAndTitles() async throws {
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
        #expect(byTitle["Lanternfall"]?.platform == .other)
        #expect(byTitle["Lanternfall"]?.appBundlePath != nil)
        #expect(byTitle["Ashen Road"]?.platform == .other)
        #expect(byTitle["Ashen Road"]?.appBundlePath == nil)
        #expect(byTitle["Ashen Road"]?.summary == "CrossOver bottle: Games")
        #expect(games.allSatisfy { $0.status == .backlog })
        #expect(summary == FolderImportSummary(found: 6, added: 4, bottlesFound: 2, crossOverAdded: 2))
        #expect(watcher.refreshCount == 1)
    }

    @Test func launcherWinsOverMatchingBottleInstall() async throws {
        let repository = try MockLibraryRepository()
        _ = try await makeImporter(repository: repository).scanConfiguredFolders()
        let lanternfall = try repository.fetchGames().filter { TitleNormalizer.matches($0.title, "Lanternfall") }
        #expect(lanternfall.count == 1)
        #expect(lanternfall.first?.appBundlePath == BundlePath.normalize(Self.lanternLauncher.path))
    }

    @Test func rescanIsIdempotent() async throws {
        let repository = try MockLibraryRepository()
        let importer = makeImporter(repository: repository)
        _ = try await importer.scanConfiguredFolders()
        let countAfterFirst = try repository.fetchGames().count
        let second = try await importer.scanConfiguredFolders()
        #expect(second.added == 0)
        #expect(second.crossOverAdded == 0)
        #expect(second.linked == 0)
        #expect(second.skipped == second.found)
        #expect(try repository.fetchGames().count == countAfterFirst)
    }

    @Test func linksExistingGameWithoutBundlePathByNormalizedTitle() async throws {
        let repository = try MockLibraryRepository()
        let logbookEntry = Game(title: "TIDEBORN!", platform: .switchPort, status: .playing)
        let alreadyTracked = Game(title: "Glimmer", platform: .macNative)
        alreadyTracked.appBundlePath = "/elsewhere/Glimmer.app"
        repository.insert(logbookEntry)
        repository.insert(alreadyTracked)
        try repository.save()

        let summary = try await makeImporter(repository: repository, installs: []).scanConfiguredFolders()

        #expect(logbookEntry.appBundlePath == BundlePath.normalize(Self.tideborn.path))
        #expect(logbookEntry.status == .playing)
        #expect(summary.linked == 1)
        let games = try repository.fetchGames()
        #expect(games.count { TitleNormalizer.matches($0.title, "Tideborn") } == 1)
        // A game that already has a different bundle path is not re-linked; the new bundle becomes its own entry.
        #expect(games.count { $0.title == "Glimmer" } == 2)
    }

    @Test func bottleInstallMatchingExistingTitleIsSkipped() async throws {
        let repository = try MockLibraryRepository()
        repository.insert(Game(title: "Ashen Road", platform: .other))
        try repository.save()
        let summary = try await makeImporter(repository: repository, folders: []).scanConfiguredFolders()
        #expect(try repository.fetchGames().count { $0.title == "Ashen Road" } == 1)
        #expect(summary.crossOverAdded == 1)
        #expect(summary.skipped == 1)
    }

    @Test func reportsUnreadableFolders() async throws {
        let repository = try MockLibraryRepository()
        let summary = try await makeImporter(repository: repository, folders: ["/missing"], installs: [])
            .scanConfiguredFolders()
        #expect(summary.unreadableFolders == ["/missing"])
        #expect(summary.description.contains("Could not read: /missing"))
    }

    @Test func scanRecordsSteamProvenance() throws {
        let repository = try MockLibraryRepository()
        var discovery = FolderDiscovery()
        discovery.steamInstalls = MockSteamInstallScanner().installs
        let summary = try makeImporter(repository: repository, folders: []).apply(discovery)
        let portal = try #require(try repository.fetchGames().first { $0.steamAppID == 620 })
        #expect(portal.steamInstalls.map(\.kind) == [.mac, .crossOver])
        #expect(summary.steam?.added == 1)
        #expect(summary.description.contains("Steam installs: 1 Mac, 1 CrossOver"))
    }
}
