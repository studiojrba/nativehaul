/// In-memory ``AppearanceStoring`` for previews and tests.
@MainActor
final class InMemoryAppearanceStore: AppearanceStoring {
    /// The saved choice.
    private(set) var stored: AppearancePreference?

    /// Creates the store, optionally with a saved choice.
    init(_ preference: AppearancePreference? = nil) {
        stored = preference
    }

    func load() -> AppearancePreference? {
        stored
    }

    func save(_ preference: AppearancePreference) {
        stored = preference
    }
}
