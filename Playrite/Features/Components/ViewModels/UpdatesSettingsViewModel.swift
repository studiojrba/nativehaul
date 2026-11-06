import Foundation
import Observation

/// Settings → Updates: every component with current → latest, the auto-update switch (off by default) and the
/// notify-only Retriever release check.
@MainActor
@Observable
final class UpdatesSettingsViewModel {
    /// Retriever's releases page.
    static let releasesURL = URL(string: "https://github.com/studiojrba/retriever/releases")

    /// One control per component.
    let rows: [ComponentInstallViewModel]
    /// Whether a check is running.
    private(set) var isChecking = false
    private let updater: any ComponentUpdating
    private var revision = 0

    /// Creates the view model.
    init(updater: any ComponentUpdating, onChanged: @escaping @MainActor () -> Void = {}) {
        self.updater = updater
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

    /// A newer Retriever release, notify-only.
    var appUpdate: String? {
        _ = revision
        return updater.appUpdate
    }

    /// Checks now, ignoring the daily throttle.
    func checkNow() async {
        isChecking = true
        defer { isChecking = false }
        await updater.checkForUpdates(force: true)
        revision += 1
    }
}
