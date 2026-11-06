import Foundation

extension AppEnvironment {
    /// Builds the library view model.
    func makeLibraryViewModel() -> LibraryViewModel {
        let viewModel = LibraryViewModel(repository: repository, transfer: transfer)
        viewModel.reload()
        return viewModel
    }

    /// Builds a game detail view model.
    func makeGameDetailViewModel(for game: Game) -> GameDetailViewModel {
        GameDetailViewModel(game: game, repository: repository)
    }

    /// Builds the Steam settings view model.
    func makeSteamSettingsViewModel() -> SteamSettingsViewModel {
        SteamSettingsViewModel(account: steamAccount)
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
}
