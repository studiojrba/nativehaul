import Foundation

/// Kinds of troubleshooting steps. Each is previewable; mutating steps are backup-first and reversible.
enum TroubleshootingStepKind: String, Codable, Sendable {
    /// Copy the engine script to a timestamped backup and record its SHA-256.
    case backupScript
    /// Apply a text patch to the engine script (requires a verified backup).
    case patchScript
    /// Re-queue the affected build.
    case rebuild
    /// Restore the engine script byte-for-byte from the backup.
    case restoreScript
    /// Verify the restored script matches the backup's hash and bytes.
    case verifyRestore
    /// Something to check on the running game. Changes nothing on the Mac; the user marks it done when checked.
    case checkGame

    /// Title of the step's action button.
    var actionTitle: String {
        self == .checkGame ? "Mark Done" : "Run"
    }
}
