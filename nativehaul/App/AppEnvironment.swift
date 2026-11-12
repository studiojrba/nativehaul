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
    /// TV mode settings (ADR 0052).
    let tvModePreferences: any TVModePreferencesStoring
    /// Sleep, Restart and Shut Down from the TV menu.
    let power: any PowerActing
    /// The current audio output, shown in the TV menu.
    let audioOutput: any AudioOutputReading
    /// Makes the controller input source for a TV mode session.
    let makeTVInput: @MainActor () -> any TVInputProviding

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
        tvModePreferences: any TVModePreferencesStoring = InMemoryTVModePreferences(),
        power: any PowerActing = RecordingPowerActions(),
        audioOutput: any AudioOutputReading = FixedAudioOutputReader(),
        makeTVInput: @escaping @MainActor () -> any TVInputProviding = { MockTVInputSource() }
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
        self.tvModePreferences = tvModePreferences
        self.power = power
        self.audioOutput = audioOutput
        self.makeTVInput = makeTVInput
    }

    /// Seeded in-memory environment with mock services for SwiftUI previews.
    static var preview: AppEnvironment {
        do {
            let repository = try MockLibraryRepository(seeded: true)
            return AppEnvironment(
                container: repository.container,
                repository: repository,
                transfer: LibraryTransferService(repository: repository),
                watcher: MockPlaytimeWatcher(),
                scanner: MockAppBundleScanner(),
                trackingPreferences: InMemoryTrackingPreferencesStore(),
                nxnativeServices: previewNXNativeServices,
                engineConfiguration: InMemoryEngineConfigurationStore(),
                hltb: CachedHLTBService(cache: InMemoryHLTBCache()),
                urlOpener: RecordingURLOpener(),
                gameFolders: InMemoryGameFolderStore(["/Users/demo/Switch/Games"]),
                folderImporter: MockGameFolderImporter(),
                deduplicator: MockLibraryDeduplicator(),
                launcher: RecordingGameLauncher(),
                metadataFetcher: MockMetadataFetcher(),
                steamGridDBKey: MockSteamGridDBKeyStore(),
                onboarding: InMemoryOnboardingStore(hasCompletedOnboarding: true),
                emulators: EmulatorRouter(preferences: InMemoryEmulatorPreferences(), files: InMemoryFileOperations()),
                components: MockComponentUpdater(),
                gameBadges: GameUpdateBadgeProvider(switchVersions: .bundled())
            )
        } catch {
            fatalError("Preview environment could not be created: \(error)")
        }
    }

    private static let previewTitleBytes = 1024

    private static var previewNXNativeServices: NXNativeServices {
        let files = InMemoryFileOperations()
        files.addFile("/Users/demo/Switch/nxnative", executable: true)
        files.addFile("/Users/demo/Switch/ProdKeys/prod.keys")
        files.addFile("/Users/demo/Switch/Staging/Tideborn.nsp", contents: Data(repeating: 0, count: previewTitleBytes))
        return NXNativeServices(
            files: files,
            disk: FixedDiskSpaceProvider(bytes: Int64.max),
            runner: MockBuildEngineRunner(),
            audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(),
            backupDirectory: "/backups",
            appBundlePath: Bundle.main.bundlePath,
            homeDirectory: "/Users/demo"
        )
    }
}
