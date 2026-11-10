import Foundation

/// nativehaul's own updates (ADR 0050). Live: ``SparkleAppUpdater``; mock: ``MockAppUpdater``.
@MainActor
protocol AppUpdating: AnyObject {
    /// Whether a manual check can start now (`false` while one is already running).
    var canCheckForUpdates: Bool { get }
    /// Whether nativehaul checks for updates by itself, once a day (on by default).
    var automaticallyChecksForUpdates: Bool { get set }
    /// Checks now and shows the result.
    func checkForUpdates()
}
