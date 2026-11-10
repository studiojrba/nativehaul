import Foundation

extension AppEnvironment {
    /// Live environment using the on-disk store, Keychain and network.
    static func live() throws -> AppEnvironment {
        let container = try ModelContainerFactory.make(inMemory: false)
        let repository = SwiftDataLibraryRepository(context: container.mainContext)
        repairStaleSessions(repository: repository)
        let secrets = KeychainSecretStore()
        let emulators = EmulatorRouter(preferences: UserDefaultsEmulatorPreferences(), files: LocalFileOperations())
        let steamAccount = SteamAccountStore(secrets: secrets)
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
            steamAccount: steamAccount,
            steamSync: makeLiveSteamSync(account: steamAccount, repository: repository),
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
            steamSignIn: makeLiveSteamSignIn(account: steamAccount),
            imageHTTP: URLSessionHTTPClient(),
            bottleInstaller: makeLiveBottleInstaller(repository: repository, account: steamAccount),
            onboarding: UserDefaultsOnboardingStore(),
            emulators: emulators,
            components: makeLiveComponents(emulators: emulators),
            gameBadges: GameUpdateBadgeProvider(files: LocalFileOperations(), switchVersions: .bundled()),
            handoff: makeLiveHandoff()
        )
    }

    /// One-time cleanup of stale tracked sessions booked before the tracker fix (ADR 0034). Runs before tracking.
    private static func repairStaleSessions(repository: any LibraryRepository) {
        TrackedSessionRepair(
            repository: repository,
            audit: FileAuditLog(path: FileAuditLog.defaultPath(), files: LocalFileOperations()),
            defaults: .standard
        ).runOnce()
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

    private static func makeLiveSteamSync(
        account: SteamAccountStore,
        repository: any LibraryRepository
    ) -> SteamSyncService {
        SteamSyncService(
            client: SteamWebAPIClient(http: URLSessionHTTPClient()),
            account: account,
            repository: repository
        )
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

    private static func makeLiveSteamSignIn(account: any SteamAccountStoring) -> SteamOpenIDSignInService {
        SteamOpenIDSignInService(
            browser: LoopbackSteamBrowserSignIn(opener: WorkspaceURLOpener()),
            verifier: SteamOpenIDVerifier(http: URLSessionHTTPClient()),
            account: account
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

    private static func makeLiveBottleInstaller(
        repository: any LibraryRepository,
        account: any SteamAccountStoring
    ) -> BottleInstallService {
        let files = LocalFileOperations()
        let runner = ProcessCommandRunner()
        let detector = CrossOverDetector(files: files)
        let client = SteamBottleClient(http: URLSessionHTTPClient(), files: files, runner: runner)
        let golden = GoldenBottleManager(
            detector: detector,
            account: account,
            store: UserDefaultsGoldenBottleStore(),
            locator: GoldenBottleLocator(files: files),
            files: files,
            runner: runner,
            client: client,
            timing: .live,
            sleeper: { try await Task.sleep(for: $0) }
        )
        return BottleInstallService(
            golden: golden,
            detector: detector,
            recipes: BundledRecipeDatabase.load(),
            disk: VolumeDiskSpaceProvider(),
            files: files,
            runner: runner,
            planner: PerGameBottlePlanner(files: files),
            client: client,
            repository: repository
        )
    }

    private static func makeLiveMetadataFetcher(
        repository: any LibraryRepository,
        secrets: any SecretStore
    ) -> MetadataFetcher {
        let http = ThrottledHTTPClient(base: URLSessionHTTPClient(), policy: .metadata)
        return MetadataFetcher(
            repository: repository,
            steamStore: SteamStoreMetadataProvider(http: http),
            nintendo: TitleDBMetadataProvider(store: TitleDBStore(http: URLSessionHTTPClient())),
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
                crossOver: CrossOverBottleScanner(),
                steamScanner: SteamInstallScanner(),
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
