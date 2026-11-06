import Foundation
import Observation

/// Live ``PlaytimeWatching``. Sessions are always stored with source ``PlaytimeSource/macTracked``
/// and are never merged into other sources.
@MainActor
@Observable
final class PlaytimeWatcher: PlaytimeWatching {
    private(set) var isRunning = false
    private(set) var activeSessions: [ActiveSession] = []
    /// Last persistence error, if any.
    private(set) var lastError: String?
    /// Called after sessions are written, so UI can refresh.
    var onSessionsRecorded: (@MainActor () -> Void)?

    @ObservationIgnored private let observer: any RunningApplicationObserving
    @ObservationIgnored private let repository: any LibraryRepository
    @ObservationIgnored private let preferences: any TrackingPreferencesStoring
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var tracker = SessionTracker(minimumSessionSeconds: TrackingPreferences
        .defaultMinimumSessionSeconds)
    @ObservationIgnored private var task: Task<Void, Never>?

    /// Creates the watcher.
    init(
        observer: any RunningApplicationObserving,
        repository: any LibraryRepository,
        preferences: any TrackingPreferencesStoring,
        now: @escaping () -> Date = { .now }
    ) {
        self.observer = observer
        self.repository = repository
        self.preferences = preferences
        self.now = now
    }

    func start() {
        let settings = preferences.load()
        guard settings.isEnabled, !isRunning else { return }
        tracker = SessionTracker(minimumSessionSeconds: settings.minimumSessionSeconds)
        refreshTrackedApps()
        for event in observer.currentlyRunning() {
            _ = tracker.handle(event)
        }
        activeSessions = tracker.activeSessions
        let stream = observer.events()
        isRunning = true
        task = Task { [weak self] in
            for await event in stream {
                self?.handle(event)
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        observer.stopObserving()
        task?.cancel()
        task = nil
        record(tracker.finishAll(at: now()))
        activeSessions = []
        isRunning = false
    }

    func refreshTrackedApps() {
        let games = (try? repository.fetchGames()) ?? []
        let tracked = games.compactMap { game in game.appBundlePath.map { ($0, game.id) } }
        tracker.setTrackedApps(Dictionary(tracked) { first, _ in first })
    }

    func attributeNextLaunch(ofAppAt path: String, to gameID: UUID) {
        tracker.expectLaunch(ofAppAt: path, for: gameID)
    }

    private func handle(_ event: RunningAppEvent) {
        if let session = tracker.handle(event) {
            record([session])
        }
        activeSessions = tracker.activeSessions
    }

    private func record(_ sessions: [CompletedSession]) {
        guard !sessions.isEmpty else { return }
        do {
            let gamesByID = try Dictionary(repository.fetchGames().map { ($0.id, $0) }) { first, _ in first }
            for completed in sessions {
                guard let game = gamesByID[completed.gameID] else { continue }
                let session = PlaySession(
                    startedAt: completed.startedAt,
                    endedAt: completed.endedAt,
                    source: .macTracked
                )
                repository.insert(session)
                session.game = game
                game.lastPlayedAt = max(game.lastPlayedAt ?? .distantPast, completed.endedAt)
            }
            try repository.save()
            lastError = nil
            onSessionsRecorded?()
        } catch {
            lastError = error.localizedDescription
        }
    }
}
