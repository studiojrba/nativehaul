import Foundation

/// Live ``ComponentPreferencesStoring`` (JSON in `UserDefaults`).
@MainActor
final class UserDefaultsComponentPreferences: ComponentPreferencesStoring {
    private static let key = "components.preferences"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var preferences: ComponentPreferences {
        get {
            defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(ComponentPreferences.self, from: $0) }
                ?? ComponentPreferences()
        }
        set { defaults.set(try? JSONEncoder().encode(newValue), forKey: Self.key) }
    }
}
