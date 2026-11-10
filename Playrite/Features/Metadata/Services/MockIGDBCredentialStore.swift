import Foundation
import Synchronization

/// ``IGDBCredentialStoring`` for previews and tests, in memory.
final class MockIGDBCredentialStore: IGDBCredentialStoring {
    private let stored: Mutex<IGDBCredentials?>

    /// Creates the store, optionally with credentials.
    init(_ credentials: IGDBCredentials? = nil) {
        stored = Mutex(credentials)
    }

    func credentials() -> IGDBCredentials? {
        stored.withLock { $0 }
    }

    func save(clientID: String, clientSecret: String) throws {
        let value = clientID.isEmpty || clientSecret.isEmpty
            ? nil
            : IGDBCredentials(clientID: clientID, clientSecret: clientSecret)
        stored.withLock { $0 = value }
    }

    func remove() throws {
        stored.withLock { $0 = nil }
    }
}
