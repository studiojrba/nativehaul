import Foundation
import Synchronization

/// Mock ``AuditLogging``.
final class InMemoryAuditLog: AuditLogging {
    private let storage = Mutex<[AuditEntry]>([])

    /// Creates an empty log.
    init() {}

    func record(_ entry: AuditEntry) throws {
        storage.withLock { $0.append(entry) }
    }

    func entries() throws -> [AuditEntry] {
        storage.withLock { $0 }
    }
}
