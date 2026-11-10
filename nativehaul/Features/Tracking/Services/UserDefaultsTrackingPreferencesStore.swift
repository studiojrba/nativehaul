import Foundation

/// Live ``TrackingPreferencesStoring`` backed by `UserDefaults` (JSON-encoded).
@MainActor
final class UserDefaultsTrackingPreferencesStore: TrackingPreferencesStoring {
    private static let key = "tracking.preferences"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> TrackingPreferences {
        guard let data = defaults.data(forKey: Self.key),
              let preferences = try? JSONDecoder().decode(TrackingPreferences.self, from: data)
        else { return TrackingPreferences() }
        return preferences
    }

    func save(_ preferences: TrackingPreferences) {
        defaults.set(try? JSONEncoder().encode(preferences), forKey: Self.key)
    }
}
