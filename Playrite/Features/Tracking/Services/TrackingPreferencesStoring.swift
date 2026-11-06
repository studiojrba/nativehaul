import Foundation

/// Persists ``TrackingPreferences``. Live: ``UserDefaultsTrackingPreferencesStore``.
@MainActor
protocol TrackingPreferencesStoring: AnyObject {
    /// Loads preferences (defaults when none saved).
    func load() -> TrackingPreferences
    /// Saves preferences.
    func save(_ preferences: TrackingPreferences)
}
