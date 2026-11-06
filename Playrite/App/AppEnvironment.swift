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
        launcher: any GameLaunching
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
    }

    /// Live environment using the on-disk store, Keychain and network.
    static func live() throws -> AppEnvironment {
        let container = try ModelContainerFactory.make(inMemory: false)
        let repository = SwiftDataLibraryRepository(context: container.mainContext)
        let steamAccount = SteamAccountStore(secrets: KeychainSecretStore())
        let steamClient = SteamWebAPIClient(http: URLSessionHTTPClient())
        let trackingPreferences = UserDefaultsTrackingPreferencesStore()
        let watcher = PlaytimeWatcher(
            observer: WorkspaceRunningApplicationObserver(),
            repository: repository,
            preferences: trackingPreferences
        )
        let hltb = CachedHLTBService(cache: FileHLTBCache())
        let deduplicator = LibraryDeduplicator(repository: repository, hltb: hltb)
        let gameFolders = UserDefaultsGameFolderStore()
        let folderImporter = makeLiveFolderImporter(
            folders: gameFolders,
            repository: repository,
            trackingPreferences: trackingPreferences,
            watcher: watcher,
            deduplicator: deduplicator
        )
        return AppEnvironment(
            container: container,
            repository: repository,
            transfer: LibraryTransferService(repository: repository, deduplicator: deduplicator),
            steamAccount: steamAccount,
            steamSync: SteamSyncService(client: steamClient, account: steamAccount, repository: repository),
            watcher: watcher,
            scanner: AppBundleScanner(),
            trackingPreferences: trackingPreferences,
            nxnativeServices: NXNativeServices(
                files: LocalFileOperations(),
                disk: VolumeDiskSpaceProvider(),
                runner: ProcessBuildEngineRunner(),
                audit: FileAuditLog(path: FileAuditLog.defaultPath(), files: LocalFileOperations()),
                knowledgeBase: BundledKnowledgeBase(),
                backupDirectory: ScriptBackupService.defaultDirectory(),
                appBundlePath: Bundle.main.bundlePath
            ),
            engineConfiguration: UserDefaultsEngineConfigurationStore(),
            hltb: hltb,
            urlOpener: WorkspaceURLOpener(),
            gameFolders: gameFolders,
            folderImporter: folderImporter,
            deduplicator: deduplicator,
            launcher: WorkspaceGameLauncher()
        )
    }

    private static func makeLiveFolderImporter(
        folders: any GameFolderStoring,
        repository: any LibraryRepository,
        trackingPreferences: any TrackingPreferencesStoring,
        watcher: any PlaytimeWatching,
        deduplicator: any LibraryDeduplicating
    ) -> GameFolderImporter {
        GameFolderImporter(
            folders: folders,
            discoverer: GameFolderDiscoverer(
                scanner: AppBundleScanner(),
                crossOver: CrossOverBottleScanner(),
                steamScanner: SteamInstallScanner(),
                measuresBundles: true
            ),
            repository: repository,
            trackingPreferences: trackingPreferences,
            watcher: watcher,
            deduplicator: deduplicator
        )
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
                engineConfiguration: InMemoryEngineConfigurationStore(EngineConfiguration(
                    isEnabled: true,
                    enginePath: "/tools/nxnative"
                )),
                hltb: CachedHLTBService(cache: InMemoryHLTBCache()),
                urlOpener: RecordingURLOpener(),
                gameFolders: InMemoryGameFolderStore(["/Users/demo/Switch/Games"]),
                folderImporter: MockGameFolderImporter(),
                deduplicator: MockLibraryDeduplicator(),
                launcher: RecordingGameLauncher()
            )
        } catch {
            fatalError("Preview environment could not be created: \(error)")
        }
    }

    private static let previewTitleBytes = 1024

    private static var previewNXNativeServices: NXNativeServices {
        let files = InMemoryFileOperations()
        files.addFile("/tools/nxnative", executable: true)
        files.addFile("/Users/demo/Switch/Staging/Tideborn.nsp", contents: Data(repeating: 0, count: previewTitleBytes))
        return NXNativeServices(
            files: files,
            disk: FixedDiskSpaceProvider(bytes: Int64.max),
            runner: MockBuildEngineRunner(),
            audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(),
            backupDirectory: "/backups",
            appBundlePath: Bundle.main.bundlePath
        )
    }
}
