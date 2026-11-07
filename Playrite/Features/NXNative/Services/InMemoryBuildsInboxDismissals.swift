import Foundation

/// Mock ``BuildsInboxDismissing``.
@MainActor
final class InMemoryBuildsInboxDismissals: BuildsInboxDismissing {
    private var keys: Set<String>

    /// Creates the store.
    init(_ keys: Set<String> = []) {
        self.keys = keys
    }

    func dismissedKeys() -> Set<String> {
        keys
    }

    func dismiss(_ key: String) {
        keys.insert(key)
    }
}
