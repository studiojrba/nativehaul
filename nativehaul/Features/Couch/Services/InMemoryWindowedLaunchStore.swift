import Foundation

/// In-memory ``WindowedLaunchStoring`` for previews and tests.
@MainActor
final class InMemoryWindowedLaunchStore: WindowedLaunchStoring {
    private var ids: Set<UUID>

    /// Creates the store, optionally with games already marked.
    init(windowed ids: Set<UUID> = []) {
        self.ids = ids
    }

    func opensWindowed(_ gameID: UUID) -> Bool {
        ids.contains(gameID)
    }

    func setOpensWindowed(_ isWindowed: Bool, for gameID: UUID) {
        if isWindowed {
            ids.insert(gameID)
        } else {
            ids.remove(gameID)
        }
    }
}
