import Foundation

/// One append-only audit record for a file-changing or troubleshooting action.
struct AuditEntry: Codable, Equatable, Sendable, Identifiable {
    /// Identity.
    let id: UUID
    /// When it happened.
    let timestamp: Date
    /// Short action name (e.g. "backupScript", "cleanup.moveToTrash").
    let action: String
    /// Affected path, if any.
    let target: String?
    /// Human-readable details (hashes, destinations, outcome).
    let details: String

    /// Creates an entry.
    init(id: UUID = UUID(), timestamp: Date = .now, action: String, target: String?, details: String) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.target = target
        self.details = details
    }
}
