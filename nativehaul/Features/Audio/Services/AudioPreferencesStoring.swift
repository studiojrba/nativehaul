/// Loads and saves ``AudioPreferences``.
@MainActor
protocol AudioPreferencesStoring: AnyObject {
    /// The saved preferences, or the defaults.
    func load() -> AudioPreferences
    /// Saves the preferences.
    func save(_ preferences: AudioPreferences)
}
