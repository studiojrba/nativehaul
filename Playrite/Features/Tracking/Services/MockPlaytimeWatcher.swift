import Foundation
import Observation

/// Mock ``PlaytimeWatching`` for previews.
@MainActor
@Observable
final class MockPlaytimeWatcher: PlaytimeWatching {
    private(set) var isRunning = false
    /// Sessions to show as active.
    var activeSessions: [ActiveSession] = []
    /// Number of refresh calls.
    private(set) var refreshCount = 0

    /// Creates the mock.
    init() {}

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    func refreshTrackedApps() {
        refreshCount += 1
    }

    /// Attributions requested, in order.
    private(set) var attributions: [(path: String, gameID: UUID)] = []

    func attributeNextLaunch(ofAppAt path: String, to gameID: UUID) {
        attributions.append((path, gameID))
    }
}
