import Foundation
@testable import Playrite
import Testing

@MainActor
struct EmulationTests {
    private let retroArch = "/Applications/RetroArch.app"

    private typealias Preferences = InMemoryEmulatorPreferences

    private func router(_ files: InMemoryFileOperations, preferences: Preferences = .init()) -> EmulatorRouter {
        EmulatorRouter(preferences: preferences, files: files, appFolders: ["/Applications"])
    }

    private func rom(_ path: String, _ system: EmulatedSystem) -> Game {
        let game = Game(title: "ROM", platform: .emulated)
        game.romPath = path
        game.emulatedSystem = system
        return game
    }

    @Test(arguments: [
        ("/roms/Metroid Fusion (USA).gba", EmulatedSystem.gameBoyAdvance),
        ("/roms/Zelda.SFC", .snes),
        ("/roms/PS2/Okami.iso", .playStation2),
        ("/roms/PlayStation 2/Okami.chd", .playStation2),
        ("/roms/PlayStation/FF7.chd", .playStation),
        ("/roms/GameCube/Melee.rvz", .gameCube),
        ("/roms/GC/Melee.iso", .gameCube),
        ("/roms/Wii/Galaxy.rvz", .wii),
        ("/roms/PSP/Patapon.iso", .psp),
    ])
    func classifiesBySystem(path: String, system: EmulatedSystem) {
        #expect(RomFileClassifier.system(forFileAt: path) == system)
    }

    @Test(arguments: ["/roms/Mystery.iso", "/roms/Wii U/Mario.iso", "/roms/track.bin", "/roms/readme.txt"])
    func ambiguousOrUnknownFilesAreLeftOut(path: String) {
        #expect(RomFileClassifier.system(forFileAt: path) == nil)
    }

    @Test func titlesDropTheExtensionAndTags() {
        #expect(RomFileClassifier.title(forFileAt: "/r/Metroid Fusion (USA) [!].gba") == "Metroid Fusion")
        #expect(RomFileClassifier.title(forFileAt: "/r/super_mario_world.sfc") == "super mario world")
    }

    @Test func retroArchLaunchesWithTheCoreAndRomAndCreditsPlaytime() {
        let files = InMemoryFileOperations()
        files.addDirectory(retroArch)
        files.addFile("/roms/Fusion.gba")
        files.addFile(EmulatorCatalog.corePath("mgba_libretro"))
        let game = rom("/roms/Fusion.gba", .gameBoyAdvance)
        let availability = router(files).availability(for: game)
        let option = availability.options.first
        #expect(option?.title == "Play in RetroArch")
        #expect(option?.isTracked == true)
        #expect(option?.trackedAppPath == retroArch)
        #expect(option?.target == .applicationWithArguments(
            path: retroArch,
            arguments: ["-L", EmulatorCatalog.corePath("mgba_libretro"), "/roms/Fusion.gba"]
        ))
    }

    @Test func missingEmulatorSaysSoWithItsOfficialPage() {
        let files = InMemoryFileOperations()
        files.addFile("/roms/Fusion.gba")
        guard case let .needsApp(reason, url) = router(files).availability(for: rom(
            "/roms/Fusion.gba",
            .gameBoyAdvance
        ))
        else {
            Issue.record("Expected needsApp")
            return
        }
        #expect(reason == "RetroArch isn't installed.")
        #expect(url?.host() == "www.retroarch.com")
    }

    @Test func missingCoreExplainsWhereToGetIt() {
        let files = InMemoryFileOperations()
        files.addDirectory(retroArch)
        files.addFile("/roms/Fusion.gba")
        guard case let .unavailable(reason) = router(files).availability(for: rom("/roms/Fusion.gba", .gameBoyAdvance))
        else {
            Issue.record("Expected unavailable")
            return
        }
        #expect(reason.contains("Core Downloader"))
    }

    @Test func pcsx2AsksForTheUsersBiosAndPlacesIt() throws {
        let files = InMemoryFileOperations()
        files.addDirectory("/Applications/PCSX2.app")
        files.addFile("/roms/PS2/Okami.iso")
        files.addFile("/Users/me/Desktop/scph.bin", contents: Data("bios".utf8))
        let router = router(files)
        let game = rom("/roms/PS2/Okami.iso", .playStation2)
        guard case let .needsUserFile(request) = router.availability(for: game) else {
            Issue.record("Expected a BIOS prompt")
            return
        }
        #expect(request.prompt == "Please provide your PlayStation 2 BIOS")
        let outcome = try router.provide("/Users/me/Desktop/scph.bin", for: request)
        guard case let .placed(path) = outcome else {
            Issue.record("Expected placed")
            return
        }
        #expect(path.hasSuffix("/PCSX2/bios/scph.bin"))
        #expect(router.availability(for: game).options.first?.target == .applicationWithArguments(
            path: "/Applications/PCSX2.app",
            arguments: ["--", "/roms/PS2/Okami.iso"]
        ))
        #expect(try router.provide("/Users/me/Desktop/scph.bin", for: request) == .alreadyPresent(path))
    }

    @Test func overrideSwitchesTheEmulatorAndBadOverridesFallBack() {
        let files = InMemoryFileOperations()
        files.addDirectory("/Applications/Dolphin.app")
        files.addFile("/roms/GameCube/Melee.rvz")
        let preferences = InMemoryEmulatorPreferences()
        let router = router(files, preferences: preferences)
        router.setProfile(EmulatorCatalog.dolphin, for: .gameCube)
        #expect(router.availability(for: rom("/roms/GameCube/Melee.rvz", .gameCube)).options.first?.target
            == .applicationWithArguments(
                path: "/Applications/Dolphin.app",
                arguments: ["-e", "/roms/GameCube/Melee.rvz"]
            ))
        preferences.setProfileID("pcsx2", for: .gameCube)
        #expect(router.profile(for: .gameCube).id == "retroarch")
    }

    @Test func expectedLaunchCreditsTheRomOnceThenNothing() {
        var tracker = SessionTracker(minimumSessionSeconds: 0)
        let gameID = UUID()
        let start = Date(timeIntervalSince1970: 0)
        tracker.expectLaunch(ofAppAt: retroArch, for: gameID)
        _ = tracker.handle(.launched(bundlePath: retroArch, processID: 1, at: start))
        let session = tracker.handle(.terminated(
            bundlePath: retroArch,
            processID: 1,
            at: start.addingTimeInterval(600)
        ))
        #expect(session.first?.gameID == gameID)
        _ = tracker.handle(.launched(bundlePath: retroArch, processID: 2, at: start))
        #expect(tracker.activeSessions.isEmpty)
    }

    @Test func launchingRegistersTheAttributionBeforeOpeningTheEmulator() async {
        let files = InMemoryFileOperations()
        files.addDirectory(retroArch)
        files.addFile("/roms/Fusion.gba")
        files.addFile(EmulatorCatalog.corePath("mgba_libretro"))
        let watcher = MockPlaytimeWatcher()
        let launcher = RecordingGameLauncher()
        let game = rom("/roms/Fusion.gba", .gameBoyAdvance)
        let viewModel = GameLaunchViewModel(game: game, launcher: launcher, watcher: watcher, emulators: router(files))
        await viewModel.launch()
        #expect(watcher.attributions.map(\.path) == [retroArch])
        #expect(watcher.attributions.first?.gameID == game.id)
        #expect(watcher.isRunning)
    }

    @Test func folderScanAddsEachRomOnceAndNeverMergesItWithASteamGame() throws {
        let repository = try MockLibraryRepository()
        let steamGame = Game(title: "Okami", platform: .steam)
        steamGame.steamAppID = 587_620
        repository.insert(steamGame)
        try repository.save()
        let importer = GameFolderImporter(
            folders: InMemoryGameFolderStore([]),
            discoverer: GameFolderDiscoverer(scanner: MockAppBundleScanner(), crossOver: MockCrossOverScanner()),
            repository: repository,
            trackingPreferences: InMemoryTrackingPreferencesStore(),
            deduplicator: LibraryDeduplicator(
                repository: repository,
                hltb: CachedHLTBService(cache: InMemoryHLTBCache())
            )
        ) { _ in false }
        var discovery = FolderDiscovery()
        discovery.roms = [DiscoveredRom(path: "/roms/PS2/Okami.iso", title: "Okami", system: .playStation2)]
        let first = try importer.apply(discovery)
        let second = try importer.apply(discovery)
        #expect(first.romsAdded == 1)
        #expect(second.romsAdded == 0)
        let games = try repository.fetchGames()
        #expect(games.count == 2)
        #expect(games.first { $0.platform == .emulated }?.emulatedSystem == .playStation2)
    }

    @Test func steamStoreIsNotAskedAboutRoms() {
        let query = MetadataQuery(gameID: UUID(), title: "Okami", steamAppID: nil, platform: .emulated)
        #expect(!SteamStoreMetadataProvider(http: MockHTTPClient()).applies(to: query))
    }

    @Test func platformNameShowsTheSystem() {
        #expect(GameInfoBuilder.platformName(rom("/r.gba", .gameBoyAdvance)) == "Emulated · Game Boy Advance")
    }
}
