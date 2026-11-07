import Foundation

extension AppEnvironment {
    /// Builds the library view model.
    func makeLibraryViewModel() -> LibraryViewModel {
        let viewModel = LibraryViewModel(
            repository: repository,
            transfer: transfer,
            folderImporter: folderImporter,
            metadataFetcher: metadataFetcher,
            steamSync: steamSync,
            components: components
        )
        viewModel.reload()
        return viewModel
    }

    /// Builds a game detail view model.
    func makeGameDetailViewModel(for game: Game) -> GameDetailViewModel {
        GameDetailViewModel(game: game, repository: repository, hltb: hltb)
    }

    /// Builds the Steam setup flow (Settings → Steam and the Steam screen's empty state).
    func makeSteamConnectionViewModel() -> SteamConnectionViewModel {
        SteamConnectionViewModel(
            account: steamAccount,
            signIn: steamSignIn,
            sync: steamSync,
            opener: urlOpener,
            http: imageHTTP,
            onChanged: LibraryChangeNotification.post
        )
    }

    /// Builds the Steam dashboard view model.
    func makeSteamDashboardViewModel(onLibraryChanged: @escaping @MainActor () -> Void) -> SteamDashboardViewModel {
        SteamDashboardViewModel(sync: steamSync, onLibraryChanged: onLibraryChanged)
    }

    /// Builds the achievements view model for a Steam game.
    func makeSteamAchievementsViewModel(for game: Game) -> SteamAchievementsViewModel {
        SteamAchievementsViewModel(game: game, sync: steamSync)
    }

    /// Builds the tracking dashboard view model.
    func makeTrackingViewModel(onLibraryChanged: @escaping @MainActor () -> Void) -> TrackingViewModel {
        TrackingViewModel(
            watcher: watcher,
            scanner: scanner,
            preferences: trackingPreferences,
            repository: repository,
            onLibraryChanged: onLibraryChanged
        )
    }

    /// Builds the detail-screen tracking view model.
    func makeTrackedAppViewModel(for game: Game) -> TrackedAppViewModel {
        TrackedAppViewModel(game: game, repository: repository, watcher: watcher)
    }

    /// Builds the tracking settings view model.
    func makeTrackingSettingsViewModel() -> TrackingSettingsViewModel {
        TrackingSettingsViewModel(store: trackingPreferences, watcher: watcher)
    }

    /// Builds the series list view model.
    func makeSeriesListViewModel() -> SeriesListViewModel {
        SeriesListViewModel(repository: repository)
    }

    /// Builds a series detail view model.
    func makeSeriesDetailViewModel(for series: Series) -> SeriesDetailViewModel {
        SeriesDetailViewModel(series: series, repository: repository)
    }

    /// Builds the detail-screen series membership view model.
    func makeSeriesMembershipViewModel(for game: Game) -> SeriesMembershipViewModel {
        SeriesMembershipViewModel(game: game, repository: repository)
    }

    /// Builds the collections list view model.
    func makeCollectionsViewModel() -> CollectionsViewModel {
        CollectionsViewModel(repository: repository)
    }

    /// Builds a collection detail view model.
    func makeCollectionDetailViewModel(for collection: GameCollection) -> CollectionDetailViewModel {
        CollectionDetailViewModel(collection: collection, repository: repository)
    }

    /// Builds the stats view model.
    func makeStatsViewModel() -> StatsViewModel {
        StatsViewModel(provider: RepositorySnapshotProvider(repository: repository), hltb: hltb)
    }

    /// Builds the NXNative queue view model. Finished apps are added to the library and tracked.
    func makeNXNativeViewModel(onLibraryChanged: @escaping @MainActor () -> Void) -> NXNativeViewModel {
        let registrar = BuiltAppRegistrar(repository: repository, watcher: watcher)
        return NXNativeViewModel(services: nxnativeServices, store: engineConfiguration) { title, appPath in
            _ = try? registrar.register(
                title: title.name,
                appPath: appPath,
                titleID: title.titleID,
                version: title.version
            )
            onLibraryChanged()
        }
    }

    /// Builds the Builds page inbox (ADR 0024) feeding `queue`. Built Switch apps in the library are not offered again.
    func makeBuildsInboxViewModel(queue: NXNativeViewModel) -> BuildsInboxViewModel {
        let repository = repository
        return BuildsInboxViewModel(
            files: nxnativeServices.files,
            store: engineConfiguration,
            dismissals: inboxDismissals,
            watcher: inboxWatcher,
            queue: queue
        ) {
            ((try? repository.fetchGames()) ?? [])
                .filter { $0.appBundlePath != nil && ($0.platform == .switchPort || $0.switchTitleID != nil) }
                .map { BuiltTitle(titleID: $0.switchTitleID, name: $0.title) }
        }
    }

    /// Builds a troubleshooting view model for a case, targeting the configured engine script.
    func makeTroubleshootingViewModel(
        for troubleshootingCase: TroubleshootingCase,
        onRebuild: @escaping @MainActor () -> Void
    ) -> TroubleshootingViewModel {
        let services = nxnativeServices
        let backups = ScriptBackupService(
            files: services.files,
            audit: services.audit,
            backupDirectory: services.backupDirectory
        )
        let session = TroubleshootingSession(
            troubleshootingCase: troubleshootingCase,
            scriptPath: EngineConfiguration.expand(services.locator.resolve(engineConfiguration.load()).enginePath),
            backups: backups,
            patcher: ScriptPatcher(files: services.files, audit: services.audit, backups: backups),
            onRebuild: onRebuild
        )
        return TroubleshootingViewModel(session: session, audit: services.audit)
    }

    /// Builds the NXNative settings view model.
    func makeNXNativeSettingsViewModel() -> NXNativeSettingsViewModel {
        NXNativeSettingsViewModel(store: engineConfiguration, locator: nxnativeServices.locator)
    }

    /// Builds the guides view model for a game.
    func makeGuidesViewModel(for game: Game) -> GuidesViewModel {
        GuidesViewModel(game: game, repository: repository, opener: urlOpener)
    }

    /// Builds the HLTB view model for a game.
    func makeHLTBViewModel(for game: Game) -> HLTBViewModel {
        HLTBViewModel(game: game, service: hltb, opener: urlOpener)
    }

    /// Builds the Game Folders settings view model.
    func makeGameFoldersViewModel(
        onLibraryChanged: @escaping @MainActor () -> Void = LibraryChangeNotification.post
    ) -> GameFoldersViewModel {
        GameFoldersViewModel(store: gameFolders, importer: folderImporter, onLibraryChanged: onLibraryChanged)
    }

    /// Builds the Merge Duplicate Games view model.
    func makeMergeDuplicatesViewModel(onLibraryChanged: @escaping @MainActor () -> Void) -> MergeDuplicatesViewModel {
        MergeDuplicatesViewModel(deduplicator: deduplicator, onLibraryChanged: onLibraryChanged)
    }

    /// Builds the Settings → Artwork view model.
    func makeArtworkSettingsViewModel() -> ArtworkSettingsViewModel {
        ArtworkSettingsViewModel(store: steamGridDBKey)
    }

    /// Builds the Manage sheet metadata view model for a game.
    func makeGameMetadataViewModel(for game: Game) -> GameMetadataViewModel {
        GameMetadataViewModel(game: game, fetcher: metadataFetcher, onChanged: LibraryChangeNotification.post)
    }

    /// Builds Settings → Emulators.
    func makeEmulatorSettingsViewModel() -> EmulatorSettingsViewModel {
        EmulatorSettingsViewModel(router: emulators, components: components)
    }

    /// Builds Settings → Updates.
    func makeUpdatesSettingsViewModel() -> UpdatesSettingsViewModel {
        UpdatesSettingsViewModel(updater: components)
    }

    /// Builds the first-run walkthrough. `onFinish` closes it.
    func makeOnboardingViewModel(onFinish: @escaping @MainActor () -> Void) -> OnboardingViewModel {
        OnboardingViewModel(
            store: onboarding,
            status: LiveOnboardingStatus(
                gameFolders: gameFolders,
                steamAccount: steamAccount,
                bottles: bottleInstaller,
                tracking: trackingPreferences,
                emulators: emulators
            ),
            onFinish: onFinish
        )
    }

    /// Builds the one-click Download panel view model for a game.
    func makeBottleInstallViewModel(for game: Game) -> BottleInstallViewModel {
        BottleInstallViewModel(game: game, installer: bottleInstaller, onChanged: LibraryChangeNotification.post)
    }

    /// Builds the launch view model for a game.
    func makeGameLaunchViewModel(for game: Game) -> GameLaunchViewModel {
        GameLaunchViewModel(game: game, launcher: launcher, watcher: watcher, emulators: emulators)
    }
}
