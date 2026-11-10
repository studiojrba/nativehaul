import Foundation
import Observation
import Sparkle

/// ``AppUpdating`` backed by Sparkle's standard updater and its own update windows (ADR 0050). The feed, signing key
/// and defaults live in `Info.plist`.
@MainActor
@Observable
final class SparkleAppUpdater: AppUpdating {
    /// Mirrors Sparkle's `canCheckForUpdates` so the menu item can disable itself.
    private(set) var canCheckForUpdates = false
    @ObservationIgnored private let controller: SPUStandardUpdaterController
    @ObservationIgnored private var observation: NSKeyValueObservation?

    /// Starts Sparkle. Create once per app run.
    init() {
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        canCheckForUpdates = controller.updater.canCheckForUpdates
        observation = controller.updater.observe(\.canCheckForUpdates, options: [.new]) { [weak self] updater, _ in
            let value = updater.canCheckForUpdates
            // Sparkle changes this property on the main thread.
            MainActor.assumeIsolated { self?.canCheckForUpdates = value }
        }
    }

    /// Sparkle's own setting, persisted in the app's defaults.
    var automaticallyChecksForUpdates: Bool {
        get {
            access(keyPath: \.automaticallyChecksForUpdates)
            return controller.updater.automaticallyChecksForUpdates
        }
        set {
            withMutation(keyPath: \.automaticallyChecksForUpdates) {
                controller.updater.automaticallyChecksForUpdates = newValue
            }
        }
    }

    /// Checks now with Sparkle's standard UI.
    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }
}
