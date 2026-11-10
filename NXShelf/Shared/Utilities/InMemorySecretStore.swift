import Foundation
import Synchronization

/// Mock ``SecretStore`` for previews and tests. Never used by the live app.
final class InMemorySecretStore: SecretStore {
    private let storage: Mutex<[SecretKey: String]>

    /// Creates a store with optional initial values.
    init(_ initial: [SecretKey: String] = [:]) {
        storage = Mutex(initial)
    }

    func secret(for key: SecretKey) throws -> String? {
        storage.withLock { $0[key] }
    }

    func setSecret(_ value: String, for key: SecretKey) throws {
        storage.withLock { $0[key] = value }
    }

    func removeSecret(for key: SecretKey) throws {
        storage.withLock { $0[key] = nil }
    }
}
