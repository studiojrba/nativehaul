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
    /// Steam account configuration (key in Keychain).
    let steamAccount: any SteamAccountStoring
    /// Steam synchronisation.
    let steamSync: any SteamSyncing
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
    /// Game folder + CrossOver import.
    let folderImporter: any GameFolderImporting
    /// Same-title duplicate merging.
    let deduplicator: any LibraryDeduplicating
    /// Starts games (apps, Steam, CrossOver).
    let launcher: any GameLaunching
    /// Fills metadata and artwork.
    let metadataFetcher: any MetadataFetching
    /// Optional SteamGridDB key (Keychain).
    let steamGridDBKey: any SteamGridDBKeyStoring
    /// Optional IGDB credentials (Keychain), ADR 0038.
    let igdbCredentials: any IGDBCredentialStoring
    /// "Sign in through Steam" (identity only).
    let steamSignIn: any SteamSigningIn
    /// Downloads small images such as the Steam avatar (`nil` in previews).
    let imageHTTP: (any HTTPClient)?
    /// One-click Windows installs through CrossOver.
    let bottleInstaller: any BottleInstalling
    /// Whether first-run setup was finished or skipped.
    let onboarding: any OnboardingStoring
    /// Routes emulated games to their emulator app.
    let emulators: EmulatorRouter
    /// Managed components (emulator installs and updates).
    let components: any ComponentUpdating
    /// Per-source game update badges.
    let gameBadges: GameUpdateBadgeProvider
    /// Keeps Retriever out of the way while a launched game runs (ADR 0030 Layer 1).
    let handoff: GameSessionHandoff

    /// Creates an environment from explicit dependencies.
    init(
        container: ModelContainer,
        repository: any LibraryRepository,
        transfer: any LibraryTransferring,
        steamAccount: any SteamAccountStoring,
        steamSync: any SteamSyncing,
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
        steamSignIn: any SteamSigningIn,
        imageHTTP: (any HTTPClient)?,
        bottleInstaller: any BottleInstalling,
        onboarding: any OnboardingStoring,
        emulators: EmulatorRouter,
        components: any ComponentUpdating,
        gameBadges: GameUpdateBadgeProvider,
        handoff: GameSessionHandoff? = nil
    ) {
        self.container = container
        self.repository = repository
        self.transfer = transfer
        self.steamAccount = steamAccount
        self.steamSync = steamSync
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
        self.steamSignIn = steamSignIn
        self.imageHTTP = imageHTTP
        self.bottleInstaller = bottleInstaller
        self.onboarding = onboarding
        self.emulators = emulators
        self.components = components
        self.gameBadges = gameBadges
        self.handoff = handoff
            ?? GameSessionHandoff(visibility: MockAppVisibility(), observer: MockRunningApplicationObserver())
    }

    /// Seeded in-memory environment with mock services for SwiftUI previews.
    static var preview: AppEnvironment {
        do {
            let repository = try MockLibraryRepository(seeded: true)
            let steamAccount = MockSteamAccountStore(configured: true)
            return AppEnvironment(
                container: repository.container,
                repository: repository,
                transfer: LibraryTransferService(repository: repository),
                steamAccount: steamAccount,
                steamSync: SteamSyncService(client: MockSteamClient(), account: steamAccount, repository: repository),
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
                steamSignIn: MockSteamSignInService(account: steamAccount),
                imageHTTP: nil,
                bottleInstaller: MockBottleInstaller(goldenStatus: .notSetUp),
                onboarding: InMemoryOnboardingStore(hasCompletedOnboarding: true),
                emulators: EmulatorRouter(preferences: InMemoryEmulatorPreferences(), files: InMemoryFileOperations()),
                components: MockComponentUpdater(),
                gameBadges: GameUpdateBadgeProvider(files: InMemoryFileOperations(), switchVersions: .bundled())
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
