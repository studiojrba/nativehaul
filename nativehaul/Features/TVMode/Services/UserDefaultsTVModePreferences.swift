import Foundation

/// Live ``TVModePreferencesStoring`` backed by `UserDefaults` (JSON under one key).
@MainActor
final class UserDefaultsTVModePreferences: TVModePreferencesStoring {
    private static let key = "tvMode.preferences"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var preferences: TVModePreferences {
        get {
            defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(TVModePreferences.self, from: $0) }
                ?? TVModePreferences()
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Self.key)
        }
    }
}
