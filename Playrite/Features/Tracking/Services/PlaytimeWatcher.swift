import Foundation
import Observation

/// Live ``PlaytimeWatching``. Sessions are always stored with source ``PlaytimeSource/macTracked``
/// and are never merged into other sources. A liveness sweep every ``sweepInterval`` closes sessions whose exit was
/// missed and stops (and flags) any stretch past the cap (ADR 0034).
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
    @ObservationIgnored private var sweepTask: Task<Void, Never>?
    @ObservationIgnored private let sleep: @Sendable (Duration) async -> Void

    /// How often running games are checked for liveness and the cap.
    static let sweepInterval: Duration = .seconds(sweepIntervalSeconds)

    private static let sweepIntervalSeconds = 60

    /// Creates the watcher.
    init(
        observer: any RunningApplicationObserving,
        repository: any LibraryRepository,
        preferences: any TrackingPreferencesStoring,
        now: @escaping () -> Date = { .now },
        sleep: @escaping @Sendable (Duration) async -> Void = { try? await Task.sleep(for: $0) }
    ) {
        self.sleep = sleep
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
            record(tracker.handle(event))
        }
        activeSessions = tracker.activeSessions
        let stream = observer.events()
        isRunning = true
        task = Task { [weak self] in
            for await event in stream {
                self?.handle(event)
            }
        }
        sweepTask = Task { [weak self, sleep] in
            while !Task.isCancelled {
                await sleep(Self.sweepInterval)
                guard !Task.isCancelled else { return }
                self?.sweep()
            }
        }
    }

    /// Checks running games once: closes sessions whose exit was missed and stops stretches past the cap.
    func sweep() {
        record(tracker.sweep(at: now()) { [observer] processID, path in
            observer.isRunning(processID: processID, bundlePath: path)
        })
        activeSessions = tracker.activeSessions
    }

    func stop() {
        guard isRunning else { return }
        observer.stopObserving()
        task?.cancel()
        task = nil
        sweepTask?.cancel()
        sweepTask = nil
        record(tracker.finishAll(at: now()))
        activeSessions = []
        isRunning = false
    }

    func refreshTrackedApps() {
        let games = (try? repository.fetchGames()) ?? []
        let tracked = games.compactMap { game in game.appBundlePath.map { ($0, game.id) } }
        tracker.setTrackedApps(Dictionary(tracked) { first, _ in first })
        let ends = games.compactMap { game in
            game.sessions.filter { $0.source == .macTracked }.map(\.endedAt).max().map { (game.id, $0) }
        }
        tracker.setLastRecordedEnds(Dictionary(ends) { first, _ in first })
    }

    func attributeNextLaunch(ofAppAt path: String, to gameID: UUID) {
        tracker.expectLaunch(ofAppAt: path, for: gameID)
    }

    private func handle(_ event: RunningAppEvent) {
        record(tracker.handle(event))
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
                    source: .macTracked,
                    note: completed.isCapped ? CompletedSession.noteForCappedSession : ""
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
