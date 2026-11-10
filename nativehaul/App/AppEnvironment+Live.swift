import Foundation

extension AppEnvironment {
    /// Live environment using the on-disk store, Keychain and network.
    static func live() throws -> AppEnvironment {
        let container = try ModelContainerFactory.make(inMemory: false)
        let repository = SwiftDataLibraryRepository(context: container.mainContext)
        let secrets = KeychainSecretStore()
        let emulators = EmulatorRouter(preferences: UserDefaultsEmulatorPreferences(), files: LocalFileOperations())
        let trackingPreferences = UserDefaultsTrackingPreferencesStore()
        let watcher = makeLiveWatcher(repository: repository, preferences: trackingPreferences)
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
            watcher: watcher,
            scanner: AppBundleScanner(),
            trackingPreferences: trackingPreferences,
            nxnativeServices: liveNXNativeServices,
            engineConfiguration: UserDefaultsEngineConfigurationStore(),
            hltb: hltb,
            urlOpener: WorkspaceURLOpener(),
            gameFolders: gameFolders,
            folderImporter: folderImporter,
            deduplicator: deduplicator,
            launcher: WorkspaceGameLauncher(),
            metadataFetcher: makeLiveMetadataFetcher(repository: repository, secrets: secrets),
            steamGridDBKey: SteamGridDBKeyStore(secrets: secrets),
            igdbCredentials: IGDBCredentialStore(secrets: secrets),
            retroAchievementsCredentials: RetroAchievementsCredentialStore(secrets: secrets),
            retroAchievements: RetroAchievementsService(client: RetroAchievementsClient(
                http: ThrottledHTTPClient(base: URLSessionHTTPClient(), policy: .metadata),
                credentials: RetroAchievementsCredentialStore(secrets: secrets)
            )),
            onboarding: UserDefaultsOnboardingStore(),
            emulators: emulators,
            components: makeLiveComponents(emulators: emulators),
            gameBadges: GameUpdateBadgeProvider(switchVersions: .bundled()),
            handoff: makeLiveHandoff(),
            appUpdater: SparkleAppUpdater()
        )
    }

    private static func makeLiveWatcher(
        repository: any LibraryRepository,
        preferences: any TrackingPreferencesStoring
    ) -> PlaytimeWatcher {
        PlaytimeWatcher(
            observer: WorkspaceRunningApplicationObserver(),
            repository: repository,
            preferences: preferences
        )
    }

    private static func makeLiveHandoff() -> GameSessionHandoff {
        GameSessionHandoff(visibility: ApplicationVisibility(), observer: WorkspaceRunningApplicationObserver())
    }

    private static var liveNXNativeServices: NXNativeServices {
        NXNativeServices(
            files: LocalFileOperations(),
            disk: VolumeDiskSpaceProvider(),
            runner: ProcessBuildEngineRunner(),
            audit: FileAuditLog(path: FileAuditLog.defaultPath(), files: LocalFileOperations()),
            knowledgeBase: BundledKnowledgeBase(),
            backupDirectory: ScriptBackupService.defaultDirectory(),
            appBundlePath: Bundle.main.bundlePath
        )
    }

    private static func makeLiveComponents(emulators: EmulatorRouter) -> ComponentUpdateService {
        let files = LocalFileOperations()
        let runner = ProcessCommandRunner()
        let assessor = CodesignSignatureAssessor(runner: runner)
        return ComponentUpdateService(
            catalog: .bundled(),
            store: UserDefaultsComponentPreferences(),
            fetcher: ComponentReleaseFetcher(http: URLSessionHTTPClient()),
            installer: ComponentInstaller(
                downloader: URLSessionFileDownloader(),
                files: files,
                runner: runner,
                assessor: assessor
            ),
            files: files,
            assessor: assessor
        ) { entry in
            EmulatorCatalog.profile(id: entry.id).map(emulators.adoptInstalled)
        }
    }

    private static func makeLiveMetadataFetcher(
        repository: any LibraryRepository,
        secrets: any SecretStore
    ) -> MetadataFetcher {
        let http = ThrottledHTTPClient(base: URLSessionHTTPClient(), policy: .metadata)
        return MetadataFetcher(
            repository: repository,
            titleDB: TitleDBMetadataProvider(store: TitleDBStore(http: URLSessionHTTPClient())),
            steamGridDB: SteamGridDBMetadataProvider(http: http, secrets: secrets),
            igdb: IGDBMetadataProvider(client: IGDBClient(
                http: http,
                credentials: IGDBCredentialStore(secrets: secrets)
            )),
            downloader: ArtworkDownloader(http: http, cache: FileArtworkCache()),
            audit: FileAuditLog(path: FileAuditLog.defaultPath(), files: LocalFileOperations())
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
                measuresBundles: true,
                romScanner: FileSystemRomScanner()
            ),
            repository: repository,
            trackingPreferences: trackingPreferences,
            watcher: watcher,
            deduplicator: deduplicator
        )
    }
}
