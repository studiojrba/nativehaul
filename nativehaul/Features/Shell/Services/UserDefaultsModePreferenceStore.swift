import Foundation

/// Live ``ModePreferenceStoring`` backed by `UserDefaults`, cheap enough to read before the first window draws.
@MainActor
final class UserDefaultsModePreferenceStore: ModePreferenceStoring {
    /// The defaults key for the start-up mode.
    static let defaultModeKey = "mode.defaultMode"
    /// The defaults key for controller rumble.
    static let rumbleKey = "mode.controllerRumble"

    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var defaultMode: AppMode {
        get { defaults.string(forKey: Self.defaultModeKey).flatMap(AppMode.init(rawValue:)) ?? .desktop }
        set { defaults.set(newValue.rawValue, forKey: Self.defaultModeKey) }
    }

    var isRumbleEnabled: Bool {
        get { defaults.object(forKey: Self.rumbleKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Self.rumbleKey) }
    }
}
