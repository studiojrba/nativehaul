import Foundation

/// Live ``AudioPreferencesStoring`` backed by `UserDefaults` (JSON-encoded).
@MainActor
final class UserDefaultsAudioPreferencesStore: AudioPreferencesStoring {
    private static let key = "audio.preferences"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AudioPreferences {
        guard let data = defaults.data(forKey: Self.key),
              let preferences = try? JSONDecoder().decode(AudioPreferences.self, from: data)
        else { return AudioPreferences() }
        return preferences
    }

    func save(_ preferences: AudioPreferences) {
        defaults.set(try? JSONEncoder().encode(preferences), forKey: Self.key)
    }
}
