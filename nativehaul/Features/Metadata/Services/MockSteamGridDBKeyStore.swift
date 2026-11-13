import Foundation

/// Mock ``SteamGridDBKeyStoring`` for previews and tests.
@MainActor
final class MockSteamGridDBKeyStore: SteamGridDBKeyStoring {
    private var key: String?

    /// Creates a mock with or without a key.
    init(hasKey: Bool = false) {
        key = hasKey ? "mock-sgdb-key" : nil
    }

    var hasKey: Bool {
        key != nil
    }

    func hasKeyOffMain() async -> Bool {
        hasKey
    }

    func saveKey(_ key: String) throws {
        self.key = key.isEmpty ? nil : key
    }

    func removeKey() throws {
        key = nil
    }
}
