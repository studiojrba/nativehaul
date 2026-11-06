import Foundation

/// Pure state machine turning launch/terminate events into completed sessions for tracked bundles.
struct SessionTracker: Sendable {
    private var trackedGames: [String: UUID] = [:]
    private var expectedLaunches: [String: UUID] = [:]
    private var active: [Int32: ActiveSession] = [:]
    private let minimumSessionSeconds: Int

    /// Creates a tracker that discards sessions shorter than `minimumSessionSeconds`.
    init(minimumSessionSeconds: Int) {
        self.minimumSessionSeconds = max(0, minimumSessionSeconds)
    }

    /// Currently running tracked sessions, oldest first.
    var activeSessions: [ActiveSession] {
        active.values.sorted { $0.startedAt < $1.startedAt }
    }

    /// Replaces the set of tracked bundles (path → game ID). Paths are normalised.
    mutating func setTrackedApps(_ apps: [String: UUID]) {
        trackedGames = Dictionary(apps.map { (BundlePath.normalize($0.key), $0.value) }) { first, _ in first }
    }

    /// Credits the next launch of the app at `path` to `gameID`, once. Used for emulators, where one app runs many
    /// games; it wins over a permanent mapping for that one launch.
    mutating func expectLaunch(ofAppAt path: String, for gameID: UUID) {
        expectedLaunches[BundlePath.normalize(path)] = gameID
    }

    /// Feeds an event; returns a completed session when a tracked app terminates after the minimum length.
    mutating func handle(_ event: RunningAppEvent) -> CompletedSession? {
        switch event {
        case let .launched(path, processID, date):
            let key = BundlePath.normalize(path)
            guard active[processID] == nil,
                  let gameID = expectedLaunches.removeValue(forKey: key) ?? trackedGames[key]
            else { return nil }
            active[processID] = ActiveSession(gameID: gameID, processID: processID, startedAt: date)
            return nil
        case let .terminated(_, processID, date):
            guard let session = active.removeValue(forKey: processID) else { return nil }
            return completed(session, endedAt: date)
        }
    }

    /// Ends every active session at `date` (e.g. when Playrite quits or tracking is paused).
    mutating func finishAll(at date: Date) -> [CompletedSession] {
        let sessions = activeSessions
        active.removeAll()
        return sessions.compactMap { completed($0, endedAt: date) }
    }

    private func completed(_ session: ActiveSession, endedAt: Date) -> CompletedSession? {
        guard endedAt.timeIntervalSince(session.startedAt) >= TimeInterval(minimumSessionSeconds) else { return nil }
        return CompletedSession(gameID: session.gameID, startedAt: session.startedAt, endedAt: endedAt)
    }
}
