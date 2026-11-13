/// In-memory ``AudioPreferencesStoring`` for previews and tests.
@MainActor
final class InMemoryAudioPreferencesStore: AudioPreferencesStoring {
    /// The stored preferences.
    private(set) var preferences: AudioPreferences

    /// Creates the store.
    init(_ preferences: AudioPreferences = AudioPreferences()) {
        self.preferences = preferences
    }

    func load() -> AudioPreferences {
        preferences
    }

    func save(_ preferences: AudioPreferences) {
        self.preferences = preferences
    }
}
