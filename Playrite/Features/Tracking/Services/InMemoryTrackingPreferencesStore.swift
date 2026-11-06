import Foundation

/// Mock ``TrackingPreferencesStoring``.
@MainActor
final class InMemoryTrackingPreferencesStore: TrackingPreferencesStoring {
    private var preferences: TrackingPreferences

    /// Creates the store with initial preferences.
    init(_ preferences: TrackingPreferences = TrackingPreferences()) {
        self.preferences = preferences
    }

    func load() -> TrackingPreferences {
        preferences
    }

    func save(_ preferences: TrackingPreferences) {
        self.preferences = preferences
    }
}
