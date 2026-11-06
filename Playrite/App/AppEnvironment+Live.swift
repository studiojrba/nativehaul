import Foundation

extension AppEnvironment {
    /// Live environment using the on-disk store, Keychain and network.
    static func live() throws -> AppEnvironment {
        let container = try ModelContainerFactory.make(inMemory: false)
        let repository = SwiftDataLibraryRepository(context: container.mainContext)
        let secrets = KeychainSecretStore()
        let steamAccount = SteamAccountStore(secrets: secrets)
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
            steamSignIn: SteamOpenIDSignInService(
                authenticator: WebAuthenticationSessionRunner(),
                verifier: SteamOpenIDVerifier(http: URLSessionHTTPClient()),
                account: steamAccount
            ),
            imageHTTP: URLSessionHTTPClient(),
            bottleInstaller: makeLiveBottleInstaller(repository: repository, account: steamAccount),
            onboarding: UserDefaultsOnboardingStore()
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
            nintendo: NintendoStoreMetadataProvider(store: UnavailableNintendoStoreSearch()),
            steamGridDB: SteamGridDBMetadataProvider(http: http, secrets: secrets),
            downloader: ArtworkDownloader(http: http, cache: FileArtworkCache())
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
}
