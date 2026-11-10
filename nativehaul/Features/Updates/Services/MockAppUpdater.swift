import Foundation
import Observation

/// In-memory ``AppUpdating`` for previews and tests.
@MainActor
@Observable
final class MockAppUpdater: AppUpdating {
    /// Whether a manual check can start now.
    var canCheckForUpdates: Bool
    /// Whether automatic checks are on.
    var automaticallyChecksForUpdates: Bool
    /// How many manual checks were started.
    private(set) var checkCount = 0

    /// Creates the mock.
    init(canCheckForUpdates: Bool = true, automaticallyChecksForUpdates: Bool = true) {
        self.canCheckForUpdates = canCheckForUpdates
        self.automaticallyChecksForUpdates = automaticallyChecksForUpdates
    }

    /// Records a check.
    func checkForUpdates() {
        checkCount += 1
    }
}
