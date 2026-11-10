import Foundation
import Synchronization

/// ``RetroAchievementsCredentialStoring`` for previews and tests, in memory.
final class MockRetroAchievementsCredentialStore: RetroAchievementsCredentialStoring {
    private let stored: Mutex<RetroAchievementsCredentials?>

    /// Creates the store, optionally with credentials.
    init(_ credentials: RetroAchievementsCredentials? = nil) {
        stored = Mutex(credentials)
    }

    func credentials() -> RetroAchievementsCredentials? {
        stored.withLock { $0 }
    }

    func save(username: String, apiKey: String) throws {
        let value = username.isEmpty || apiKey.isEmpty
            ? nil
            : RetroAchievementsCredentials(username: username, apiKey: apiKey)
        stored.withLock { $0 = value }
    }

    func remove() throws {
        stored.withLock { $0 = nil }
    }
}
