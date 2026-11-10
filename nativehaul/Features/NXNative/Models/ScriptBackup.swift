import Foundation

/// Record of a byte-exact backup of an engine script.
struct ScriptBackup: Codable, Equatable, Sendable {
    /// The script that was backed up.
    let originalPath: String
    /// Where the copy lives.
    let backupPath: String
    /// SHA-256 (hex) of the original bytes.
    let sha256: String
    /// Size in bytes.
    let size: Int
    /// When the backup was taken.
    let createdAt: Date
}
