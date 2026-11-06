import Foundation

/// Append-only audit log. Live: ``FileAuditLog``; mock: ``InMemoryAuditLog``.
protocol AuditLogging: Sendable {
    /// Appends an entry.
    func record(_ entry: AuditEntry) throws
    /// All entries, oldest first.
    func entries() throws -> [AuditEntry]
}
