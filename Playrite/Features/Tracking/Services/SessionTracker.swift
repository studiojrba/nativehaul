import Foundation

/// Pure state machine turning launch, termination, sleep and liveness information into completed sessions for
/// tracked bundles (ADR 0034). One run per game, never one per process.
struct SessionTracker: Sendable {
    /// Shorthand for the sessions a step completes.
    typealias Completed = [CompletedSession]

    /// Longest stretch recorded as one session. Longer ones are stopped here and flagged (``CompletedSession``).
    static let maximumSessionSeconds = maximumSessionHours * secondsPerHour

    private static let maximumSessionHours = 12
    private static let secondsPerHour = 3600

    private var trackedGames: [String: UUID] = [:]
    private var expectedLaunches: [String: UUID] = [:]
    private var runs: [UUID: GameRun] = [:]
    private var processBundles: [Int32: (gameID: UUID, path: String)] = [:]
    private var lastRecordedEnds: [UUID: Date] = [:]
    private var isAsleep = false
    private var lastConfirmedAlive: Date?
    private let minimumSessionSeconds: Int
    private let maximumSessionSeconds: Int

    /// Creates a tracker that discards sessions shorter than `minimumSessionSeconds` and stops (and flags) stretches
    /// at `maximumSessionSeconds`.
    init(minimumSessionSeconds: Int, maximumSessionSeconds: Int = Self.maximumSessionSeconds) {
        self.minimumSessionSeconds = max(0, minimumSessionSeconds)
        self.maximumSessionSeconds = max(1, maximumSessionSeconds)
    }

    /// Games being counted right now, oldest first.
    var activeSessions: [ActiveSession] {
        runs.values.compactMap { run in
            guard let start = run.countingSince, let processID = run.firstProcessID else { return nil }
            return ActiveSession(gameID: run.gameID, processID: processID, startedAt: start)
        }
        .sorted { $0.startedAt < $1.startedAt }
    }

    /// Replaces the set of tracked bundles (path → game ID). Paths are normalised.
    mutating func setTrackedApps(_ apps: [String: UUID]) {
        trackedGames = Dictionary(apps.map { (BundlePath.normalize($0.key), $0.value) }) { first, _ in first }
    }

    /// The end of each game's last stored tracked session. A new stretch never starts before it, so a game that was
    /// already running when Retriever restarted isn't counted twice.
    mutating func setLastRecordedEnds(_ ends: [UUID: Date]) {
        lastRecordedEnds = ends
    }

    /// Credits the next launch of the app at `path` to `gameID`, once. Used for emulators, where one app runs many
    /// games; it wins over a permanent mapping for that one launch.
    mutating func expectLaunch(ofAppAt path: String, for gameID: UUID) {
        expectedLaunches[BundlePath.normalize(path)] = gameID
    }

    /// Feeds an event; returns the sessions it completed.
    mutating func handle(_ event: RunningAppEvent) -> [CompletedSession] {
        switch event {
        case let .launched(path, processID, date, role):
            return launch(path: path, processID: processID, role: role, at: date)
        case let .terminated(_, processID, date):
            return end(processID, at: date)
        case let .systemWillSleep(date):
            isAsleep = true
            return updateAll(at: date)
        case let .systemDidWake(date):
            isAsleep = false
            return updateAll(at: date)
        }
    }

    /// Checks every tracked process with `isRunning` (process ID, bundle path). A process that has gone without an
    /// exit event ends at the last sweep that saw it alive. Stretches longer than the cap are stopped and flagged.
    mutating func sweep(at date: Date, isRunning: (Int32, String) -> Bool) -> [CompletedSession] {
        let lastSeen = lastConfirmedAlive ?? date
        var completed: [CompletedSession] = []
        for (processID, bundle) in Array(processBundles) where !isRunning(processID, bundle.path) {
            completed += end(processID, at: lastSeen)
        }
        let limit = TimeInterval(maximumSessionSeconds)
        for gameID in Array(runs.keys) {
            if let stretch = runs[gameID]?.cap(at: date, limit: limit) {
                completed += session(gameID, stretch, isCapped: true)
            }
        }
        lastConfirmedAlive = date
        return completed
    }

    /// Ends every active session at `date` (e.g. when Retriever quits or tracking is paused).
    mutating func finishAll(at date: Date) -> [CompletedSession] {
        var completed: [CompletedSession] = []
        for gameID in Array(runs.keys) {
            if let stretch = runs[gameID]?.endStretch(at: date) {
                completed += session(gameID, stretch)
            }
        }
        runs.removeAll()
        processBundles.removeAll()
        return completed
    }

    private mutating func launch(path: String, processID: Int32, role: ProcessRole, at date: Date) -> Completed {
        let key = BundlePath.normalize(path)
        guard processBundles[processID] == nil,
              let gameID = expectedLaunches.removeValue(forKey: key) ?? trackedGames[key]
        else { return [] }
        processBundles[processID] = (gameID, key)
        var run = runs[gameID] ?? GameRun(gameID: gameID)
        run.add(processID, role: role, at: date)
        runs[gameID] = run
        return update(gameID, at: date)
    }

    private mutating func end(_ processID: Int32, at date: Date) -> [CompletedSession] {
        guard let bundle = processBundles.removeValue(forKey: processID) else { return [] }
        runs[bundle.gameID]?.remove(processID)
        let completed = update(bundle.gameID, at: date)
        if runs[bundle.gameID]?.isEmpty == true {
            runs.removeValue(forKey: bundle.gameID)
        }
        return completed
    }

    private mutating func updateAll(at date: Date) -> [CompletedSession] {
        var completed: [CompletedSession] = []
        for gameID in Array(runs.keys) {
            completed += update(gameID, at: date)
        }
        return completed
    }

    private mutating func update(_ gameID: UUID, at date: Date) -> [CompletedSession] {
        let notBefore = lastRecordedEnds[gameID]
        let asleep = isAsleep
        guard let stretch = runs[gameID]?.update(at: date, isAsleep: asleep, notBefore: notBefore) else { return [] }
        return session(gameID, stretch)
    }

    private func session(_ gameID: UUID, _ stretch: DateInterval, isCapped: Bool = false) -> [CompletedSession] {
        guard stretch.duration >= TimeInterval(minimumSessionSeconds) else { return [] }
        return [CompletedSession(gameID: gameID, startedAt: stretch.start, endedAt: stretch.end, isCapped: isCapped)]
    }
}
