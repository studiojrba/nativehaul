import Foundation

/// Live ``AppearanceStoring`` backed by `UserDefaults`. Read synchronously and cheaply, so the app delegate can apply
/// the choice before the first window draws.
@MainActor
final class UserDefaultsAppearanceStore: AppearanceStoring {
    /// The defaults key.
    static let key = "appearance.preference"

    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AppearancePreference? {
        defaults.string(forKey: Self.key).flatMap(AppearancePreference.init(rawValue:))
    }

    func save(_ preference: AppearancePreference) {
        defaults.set(preference.rawValue, forKey: Self.key)
    }
}
