import Foundation

/// Errors raised by troubleshooting actions. Every refusal leaves files untouched.
enum TroubleshootingError: Error, Equatable, LocalizedError {
    /// The engine script does not exist.
    case scriptMissing(String)
    /// A step was attempted without a verified backup.
    case backupRequired
    /// The backup no longer matches its recorded hash.
    case backupCorrupted
    /// The script changed since the backup was taken (so patching would lose edits).
    case scriptChangedSinceBackup
    /// The patch text was not found exactly once.
    case patchNotUnique(matches: Int)
    /// The restored script does not match the backup.
    case verificationFailed
    /// A step was run out of order.
    case outOfOrder

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case let .scriptMissing(path): "Engine script not found at \(path)."
        case .backupRequired: "Back up the engine script first."
        case .backupCorrupted: "The backup no longer matches its recorded SHA-256."
        case .scriptChangedSinceBackup: "The script changed after the backup was taken. Take a new backup first."
        case let .patchNotUnique(matches): "The patch must match exactly once (found \(matches))."
        case .verificationFailed: "The restored script does not match the backup byte-for-byte."
        case .outOfOrder: "Complete the previous steps first."
        }
    }
}
