import Foundation
import Observation

/// Tracking sidebar screen: watcher status, active sessions, tracked and discovered apps.
@MainActor
@Observable
final class TrackingViewModel {
    /// Apps found in the games folder that are not tracked yet.
    private(set) var discoveredApps: [DiscoveredApp] = []
    /// Games with a tracked bundle.
    private(set) var trackedGames: [Game] = []
    /// Last error.
    private(set) var errorMessage: String?

    private let watcher: any PlaytimeWatching
    private let scanner: any AppBundleScanning
    private let preferences: any TrackingPreferencesStoring
    private let repository: any LibraryRepository
    private let onLibraryChanged: @MainActor () -> Void

    /// Creates the view model.
    init(
        watcher: any PlaytimeWatching,
        scanner: any AppBundleScanning,
        preferences: any TrackingPreferencesStoring,
        repository: any LibraryRepository,
        onLibraryChanged: @escaping @MainActor () -> Void
    ) {
        self.watcher = watcher
        self.scanner = scanner
        self.preferences = preferences
        self.repository = repository
        self.onLibraryChanged = onLibraryChanged
    }

    /// Whether the watcher is running.
    var isWatching: Bool {
        watcher.isRunning
    }

    /// Folder being scanned.
    var gamesFolder: String {
        preferences.load().gamesFolder
    }

    /// Active sessions paired with game titles.
    var activeSessions: [(session: ActiveSession, title: String)] {
        watcher.activeSessions.map { session in
            (session, trackedGames.first { $0.id == session.gameID }?.title ?? "Unknown game")
        }
    }

    /// Reloads tracked games and rescans the games folder.
    func refresh() {
        do {
            let games = try repository.fetchGames()
            trackedGames = games.filter { $0.appBundlePath != nil }
            let trackedPaths = Set(trackedGames.compactMap(\.appBundlePath).map(BundlePath.normalize))
            discoveredApps = try scanner.scan(folder: preferences.load().expandedGamesFolder)
                .filter { !trackedPaths.contains($0.path) }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Starts or stops the watcher.
    func setWatching(_ isOn: Bool) {
        if isOn {
            var settings = preferences.load()
            settings.isEnabled = true
            preferences.save(settings)
            watcher.start()
        } else {
            watcher.stop()
        }
    }

    /// Tracks a discovered app, linking it to a same-titled game or creating a new one.
    func track(_ app: DiscoveredApp) {
        perform {
            let games = try repository.fetchGames()
            let game = TrackedAppMatcher.match(app, in: games) ?? {
                let platform = TrackedAppMatcher.platform(
                    forBundleAt: app.path,
                    gamesFolder: preferences.load().gamesFolder
                )
                let newGame = Game(title: app.name, platform: platform, status: .backlog)
                repository.insert(newGame)
                return newGame
            }()
            game.appBundlePath = app.path
        }
    }

    /// Tracks an arbitrary `.app` chosen by the user.
    func track(bundleURL: URL) {
        track(DiscoveredApp(
            name: bundleURL.deletingPathExtension().lastPathComponent,
            path: BundlePath.normalize(bundleURL.path)
        ))
    }

    /// Stops tracking a game's bundle. Recorded sessions are kept.
    func untrack(_ game: Game) {
        perform { game.appBundlePath = nil }
    }

    private func perform(_ change: () throws -> Void) {
        do {
            try change()
            try repository.save()
            watcher.refreshTrackedApps()
            onLibraryChanged()
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
