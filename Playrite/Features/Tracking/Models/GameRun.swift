import Foundation

/// One tracked game's running processes, and the stretch of time currently counted as play (ADR 0034).
///
/// - All of a game's processes make one run, so a port's launcher and its game host are never counted twice.
/// - Once a helper (a port's game host) has run, only time while a helper runs counts: a launcher window left open
///   after the game quits is not play, and the launcher's wait before the game started is dropped.
struct GameRun: Sendable {
    /// The library game.
    let gameID: UUID
    /// Live processes of the game's bundle and their roles.
    private(set) var processes: [Int32: ProcessRole] = [:]
    /// Start of the stretch being counted now, if any.
    private(set) var countingSince: Date?
    private var hasSeenHelper = false
    private var isCapped = false

    /// Creates an empty run.
    init(gameID: UUID) {
        self.gameID = gameID
    }

    /// `true` once no process of the game is left.
    var isEmpty: Bool {
        processes.isEmpty
    }

    /// The lowest live process ID, used as the run's identity in lists.
    var firstProcessID: Int32? {
        processes.keys.min()
    }

    /// Adds a process. A new process lifts a cap; the first helper restarts the count at its launch.
    mutating func add(_ processID: Int32, role: ProcessRole, at date: Date) {
        processes[processID] = role
        isCapped = false
        if role == .helper, !hasSeenHelper {
            hasSeenHelper = true
            if countingSince != nil {
                countingSince = date
            }
        }
    }

    /// Removes a process.
    mutating func remove(_ processID: Int32) {
        processes.removeValue(forKey: processID)
    }

    /// Starts or stops counting to match the run's processes. Returns the stretch that just ended, if any.
    /// A new stretch never starts before `notBefore` (the end of the game's last stored tracked session).
    mutating func update(at date: Date, isAsleep: Bool, notBefore: Date?) -> DateInterval? {
        if shouldCount(isAsleep: isAsleep) {
            if countingSince == nil {
                countingSince = max(date, notBefore ?? date)
            }
            return nil
        }
        return endStretch(at: date)
    }

    /// Ends the current stretch at `start + limit` when it has run that long, and stops counting until a new process
    /// appears.
    mutating func cap(at date: Date, limit: TimeInterval) -> DateInterval? {
        guard let start = countingSince, date.timeIntervalSince(start) >= limit else { return nil }
        isCapped = true
        return endStretch(at: start.addingTimeInterval(limit))
    }

    /// Ends the current stretch at `date`, whatever the processes.
    mutating func endStretch(at date: Date) -> DateInterval? {
        guard let start = countingSince else { return nil }
        countingSince = nil
        return DateInterval(start: start, end: max(start, date))
    }

    private func shouldCount(isAsleep: Bool) -> Bool {
        guard !isEmpty, !isCapped, !isAsleep else { return false }
        return !hasSeenHelper || processes.values.contains(.helper)
    }
}
