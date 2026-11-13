import Foundation

/// Reads the FileVault status for the couch-mode note. Live: ``FdesetupFileVaultStatus``; mock:
/// ``FixedFileVaultStatus``.
protocol FileVaultStatusProviding: Sendable {
    /// The current status (``FileVaultStatus/unknown`` when it can't be read).
    func status() async -> FileVaultStatus
}
