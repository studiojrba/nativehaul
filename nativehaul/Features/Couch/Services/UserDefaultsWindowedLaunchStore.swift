import Foundation

/// Live ``WindowedLaunchStoring``: the IDs of games marked "Open windowed", as strings in `UserDefaults`.
@MainActor
final class UserDefaultsWindowedLaunchStore: WindowedLaunchStoring {
    /// The defaults key.
    static let key = "couch.windowedGameIDs"

    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func opensWindowed(_ gameID: UUID) -> Bool {
        ids.contains(gameID.uuidString)
    }

    func setOpensWindowed(_ isWindowed: Bool, for gameID: UUID) {
        var current = ids
        if isWindowed {
            current.insert(gameID.uuidString)
        } else {
            current.remove(gameID.uuidString)
        }
        defaults.set(current.sorted(), forKey: Self.key)
    }

    private var ids: Set<String> {
        Set(defaults.stringArray(forKey: Self.key) ?? [])
    }
}
