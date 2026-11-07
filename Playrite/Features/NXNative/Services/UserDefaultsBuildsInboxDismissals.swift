import Foundation

/// Live ``BuildsInboxDismissing``: dismissed item keys in `UserDefaults` (paths and title IDs only).
@MainActor
final class UserDefaultsBuildsInboxDismissals: BuildsInboxDismissing {
    private static let key = "nxnative.inbox.dismissed"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func dismissedKeys() -> Set<String> {
        Set(defaults.stringArray(forKey: Self.key) ?? [])
    }

    func dismiss(_ key: String) {
        defaults.set((dismissedKeys().union([key])).sorted(), forKey: Self.key)
    }
}
