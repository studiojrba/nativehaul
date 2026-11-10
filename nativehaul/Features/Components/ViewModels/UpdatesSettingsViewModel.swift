import Foundation
import Observation

/// Settings → Updates: every component with current → latest, the auto-update switch (off by default), and
/// nativehaul's own updates through Sparkle (ADR 0050).
@MainActor
@Observable
final class UpdatesSettingsViewModel {
    /// One control per component.
    let rows: [ComponentInstallViewModel]
    /// Whether a check is running.
    private(set) var isChecking = false
    /// nativehaul's own updater.
    let appUpdater: any AppUpdating
    private let updater: any ComponentUpdating
    private var revision = 0

    /// Creates the view model.
    init(
        updater: any ComponentUpdating,
        appUpdater: any AppUpdating,
        onChanged: @escaping @MainActor () -> Void = {}
    ) {
        self.updater = updater
        self.appUpdater = appUpdater
        rows = updater.catalog.components.map {
            ComponentInstallViewModel(entry: $0, updater: updater, onChanged: onChanged)
        }
    }

    /// "Automatically update components" (default off).
    var autoUpdateAll: Bool {
        get {
            _ = revision
            return updater.preferences.autoUpdateAll
        }
        set {
            updater.setAutoUpdateAll(newValue)
            revision += 1
        }
    }

    /// Last check time.
    var lastChecked: Date? {
        _ = revision
        return updater.preferences.lastChecked
    }

    /// "Check for nativehaul updates automatically" (on by default; Sparkle keeps the setting).
    var checksForAppUpdates: Bool {
        get { appUpdater.automaticallyChecksForUpdates }
        set { appUpdater.automaticallyChecksForUpdates = newValue }
    }

    /// Checks now, ignoring the daily throttle.
    func checkNow() async {
        isChecking = true
        defer { isChecking = false }
        await updater.checkForUpdates(force: true)
        revision += 1
    }
}
