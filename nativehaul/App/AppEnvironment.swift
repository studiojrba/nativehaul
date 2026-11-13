import Foundation
import Observation
import SwiftData

/// Dependency container. Wires live services for the app and mocks for previews (ADR 0002).
@MainActor
@Observable
final class AppEnvironment {
    /// SwiftData container backing the repository.
    let container: ModelContainer
    /// Library persistence.
    let repository: any LibraryRepository
    /// JSON import/export.
    let transfer: any LibraryTransferring
    /// Playtime watcher for tracked `.app` bundles.
    let watcher: any PlaytimeWatching
    /// Games-folder scanner.
    let scanner: any AppBundleScanning
    /// Tracking preferences.
    let trackingPreferences: any TrackingPreferencesStoring
    /// NXNative module services (engine is external and user-supplied).
    let nxnativeServices: NXNativeServices
    /// NXNative configuration.
    let engineConfiguration: any EngineConfigurationStoring
    /// HowLongToBeat estimate cache.
    let hltb: any HLTBProviding
    /// Opens links in the browser.
    let urlOpener: any URLOpening
    /// Configured game folders.
    let gameFolders: any GameFolderStoring
    /// Game folder import (existing builds and ROM folders).
    let folderImporter: any GameFolderImporting
    /// Same-title duplicate merging.
    let deduplicator: any LibraryDeduplicating
    /// Starts games (apps and emulators).
    let launcher: any GameLaunching
    /// Fills metadata and artwork.
    let metadataFetcher: any MetadataFetching
    /// Optional SteamGridDB key (Keychain).
    let steamGridDBKey: any SteamGridDBKeyStoring
    /// Optional IGDB credentials (Keychain), ADR 0038.
    let igdbCredentials: any IGDBCredentialStoring
    /// Optional RetroAchievements credentials (Keychain), ADR 0047.
    let retroAchievementsCredentials: any RetroAchievementsCredentialStoring
    /// RetroAchievements lookups for emulated games.
    let retroAchievements: any RetroAchievementsProviding
    /// Whether first-run setup was finished or skipped.
    let onboarding: any OnboardingStoring
    /// Routes emulated games to their emulator app.
    let emulators: EmulatorRouter
    /// Managed components (emulator installs and updates).
    let components: any ComponentUpdating
    /// Per-source game update badges.
    let gameBadges: GameUpdateBadgeProvider
    /// Keeps nativehaul out of the way while a launched game runs (ADR 0030 Layer 1).
    let handoff: GameSessionHandoff
    /// nativehaul's own updates (Sparkle, ADR 0050).
    let appUpdater: any AppUpdating
    /// Background music and interface sounds (audio brief).
    let audio: AudioController
    /// Light/Dark appearance (ADR 0054).
    let appearance: AppearanceController
    /// Derives colour palettes from cover art (ADR 0054).
    let paletteExtractor: any GamePaletteExtracting
    /// Shows games in Finder (Detail, ADR 0056).
    let fileRevealer: any FileRevealing
    /// Mounted volumes, for the install step (ADR 0057).
    let volumes: any VolumeInspecting
    /// FileVault status, for the couch note (ADR 0057).
    let fileVault: any FileVaultStatusProviding
    /// Couch mode's dependencies (ADR 0057, ADR 0058).
    let couch: CouchEnvironment

    /// The mode nativehaul opens in and controller rumble (ADR 0057).
    var modePreferences: any ModePreferenceStoring {
        couch.modePreferences
    }

    /// The per-game "Open windowed" override for couch launches (ADR 0058).
    var windowedLaunches: any WindowedLaunchStoring {
        couch.windowedLaunches
    }

    /// Creates an environment from explicit dependencies.
    init(
        container: ModelContainer,
        repository: any LibraryRepository,
        transfer: any LibraryTransferring,
        watcher: any PlaytimeWatching,
        scanner: any AppBundleScanning,
        trackingPreferences: any TrackingPreferencesStoring,
        nxnativeServices: NXNativeServices,
        engineConfiguration: any EngineConfigurationStoring,
        hltb: any HLTBProviding,
        urlOpener: any URLOpening,
        gameFolders: any GameFolderStoring,
        folderImporter: any GameFolderImporting,
        deduplicator: any LibraryDeduplicating,
        launcher: any GameLaunching,
        metadataFetcher: any MetadataFetching,
        steamGridDBKey: any SteamGridDBKeyStoring,
        igdbCredentials: any IGDBCredentialStoring = MockIGDBCredentialStore(),
        retroAchievementsCredentials: any RetroAchievementsCredentialStoring = MockRetroAchievementsCredentialStore(),
        retroAchievements: any RetroAchievementsProviding = MockRetroAchievementsService(),
        onboarding: any OnboardingStoring,
        emulators: EmulatorRouter,
        components: any ComponentUpdating,
        gameBadges: GameUpdateBadgeProvider,
        handoff: GameSessionHandoff? = nil,
        appUpdater: any AppUpdating = MockAppUpdater(),
        audio: AudioController? = nil,
        appearance: AppearanceController? = nil,
        paletteExtractor: any GamePaletteExtracting = MockGamePaletteExtractor(),
        fileRevealer: (any FileRevealing)? = nil,
        volumes: any VolumeInspecting = MockVolumeInspector.preview,
        fileVault: any FileVaultStatusProviding = FixedFileVaultStatus(),
        couch: CouchEnvironment = CouchEnvironment()
    ) {
        self.container = container
        self.repository = repository
        self.transfer = transfer
        self.watcher = watcher
        self.scanner = scanner
        self.trackingPreferences = trackingPreferences
        self.nxnativeServices = nxnativeServices
        self.engineConfiguration = engineConfiguration
        self.hltb = hltb
        self.urlOpener = urlOpener
        self.gameFolders = gameFolders
        self.folderImporter = folderImporter
        self.deduplicator = deduplicator
        self.launcher = launcher
        self.metadataFetcher = metadataFetcher
        self.steamGridDBKey = steamGridDBKey
        self.igdbCredentials = igdbCredentials
        self.retroAchievementsCredentials = retroAchievementsCredentials
        self.retroAchievements = retroAchievements
        self.onboarding = onboarding
        self.emulators = emulators
        self.components = components
        self.gameBadges = gameBadges
        self.handoff = handoff
            ?? GameSessionHandoff(visibility: MockAppVisibility(), observer: MockRunningApplicationObserver())
        self.appUpdater = appUpdater
        self.audio = audio ?? .preview
        self.appearance = appearance ?? .preview
        self.paletteExtractor = paletteExtractor
        self.fileRevealer = fileRevealer ?? RecordingFileRevealer()
        self.volumes = volumes
        self.fileVault = fileVault
        self.couch = couch
    }

    /// Seeded in-memory environment with mock services for SwiftUI previews.
    static var preview: AppEnvironment {
        do {
            return try preview(repository: MockLibraryRepository(seeded: true))
        } catch {
            fatalError("Preview environment could not be created: \(error)")
        }
    }

    /// An in-memory environment over `repository`, with mock services; `runner` drives the build queue and
    /// `hasCompletedOnboarding` decides whether onboarding opens.
    static func preview(
        repository: MockLibraryRepository,
        runner: any BuildEngineRunning = MockBuildEngineRunner(),
        hasCompletedOnboarding: Bool = true
    ) -> AppEnvironment {
        AppEnvironment(
            container: repository.container,
            repository: repository,
            transfer: LibraryTransferService(repository: repository),
            watcher: MockPlaytimeWatcher(),
            scanner: MockAppBundleScanner(),
            trackingPreferences: InMemoryTrackingPreferencesStore(),
            nxnativeServices: previewNXNativeServices(runner: runner),
            engineConfiguration: InMemoryEngineConfigurationStore(),
            hltb: CachedHLTBService(cache: InMemoryHLTBCache()),
            urlOpener: RecordingURLOpener(),
            gameFolders: InMemoryGameFolderStore(["/Users/demo/Switch/Games"]),
            folderImporter: MockGameFolderImporter(),
            deduplicator: MockLibraryDeduplicator(),
            launcher: RecordingGameLauncher(),
            metadataFetcher: MockMetadataFetcher(),
            steamGridDBKey: MockSteamGridDBKeyStore(),
            onboarding: InMemoryOnboardingStore(hasCompletedOnboarding: hasCompletedOnboarding),
            emulators: EmulatorRouter(preferences: InMemoryEmulatorPreferences(), files: InMemoryFileOperations()),
            components: MockComponentUpdater(),
            gameBadges: GameUpdateBadgeProvider(switchVersions: .bundled())
        )
    }

    private static let previewTitleBytes = 1024

    private static func previewNXNativeServices(runner: any BuildEngineRunning) -> NXNativeServices {
        let files = InMemoryFileOperations()
        files.addFile("/Users/demo/Switch/nxnative", executable: true)
        files.addFile("/Users/demo/Switch/ProdKeys/prod.keys", contents: Data("preview keys".utf8))
        files.addFile("/Users/demo/Switch/Staging/Tideborn.nsp", contents: Data(repeating: 0, count: previewTitleBytes))
        return NXNativeServices(
            files: files,
            disk: FixedDiskSpaceProvider(bytes: Int64.max),
            runner: runner,
            audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(),
            backupDirectory: "/backups",
            appBundlePath: Bundle.main.bundlePath,
            homeDirectory: "/Users/demo"
        )
    }
}
