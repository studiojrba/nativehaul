import Foundation
import Observation

/// Settings → Tracking.
@MainActor
@Observable
final class TrackingSettingsViewModel {
    /// Editable preferences.
    var preferences: TrackingPreferences

    private let store: any TrackingPreferencesStoring
    private let watcher: any PlaytimeWatching

    /// Creates the view model.
    init(store: any TrackingPreferencesStoring, watcher: any PlaytimeWatching) {
        self.store = store
        self.watcher = watcher
        preferences = store.load()
    }

    /// Minimum session length in whole minutes (for the stepper).
    var minimumSessionMinutes: Int {
        get { preferences.minimumSessionSeconds / Self.secondsPerMinute }
        set { preferences.minimumSessionSeconds = max(0, newValue) * Self.secondsPerMinute }
    }

    /// Saves and restarts the watcher so changes take effect.
    func save() {
        store.save(preferences)
        watcher.stop()
        if preferences.isEnabled {
            watcher.start()
        }
    }

    private static let secondsPerMinute = 60
}
