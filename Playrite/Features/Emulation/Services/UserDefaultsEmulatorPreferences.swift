import Foundation

/// Live ``EmulatorPreferencesStoring`` in `UserDefaults`.
@MainActor
final class UserDefaultsEmulatorPreferences: EmulatorPreferencesStoring {
    private static let prefix = "emulation.profile."
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func profileID(for system: EmulatedSystem) -> String? {
        defaults.string(forKey: Self.prefix + system.rawValue)
    }

    func setProfileID(_ id: String?, for system: EmulatedSystem) {
        defaults.set(id, forKey: Self.prefix + system.rawValue)
    }
}
