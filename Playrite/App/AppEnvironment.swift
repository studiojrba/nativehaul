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
        engineConfiguration: any EngineConfigurationStoring
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
        return AppEnvironment(
            container: container,
            repository: repository,
            transfer: LibraryTransferService(repository: repository),
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
            engineConfiguration: UserDefaultsEngineConfigurationStore()
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
                ))
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
