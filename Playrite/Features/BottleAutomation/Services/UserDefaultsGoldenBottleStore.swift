import Foundation

/// Live ``GoldenBottleStoring`` in `UserDefaults` (a bottle name is not a secret).
@MainActor
final class UserDefaultsGoldenBottleStore: GoldenBottleStoring {
    private static let key = "bottleAutomation.goldenBottle"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var bottleName: String? {
        get { defaults.string(forKey: Self.key) }
        set { defaults.set(newValue, forKey: Self.key) }
    }
}
