import Foundation

/// Whether FileVault is on (TV plan Q4). Read only to inform the couch-mode choice — nativehaul never changes it.
enum FileVaultStatus: Equatable, Sendable {
    /// Encryption is on: the Mac asks for a password at startup.
    case on
    /// Encryption is off: the Mac can log in by itself.
    case off
    /// Couldn't tell.
    case unknown

    /// Reads `fdesetup status` output ("FileVault is On." / "FileVault is Off.").
    static func parse(_ output: String) -> FileVaultStatus {
        if output.contains("FileVault is On") {
            return .on
        }
        if output.contains("FileVault is Off") {
            return .off
        }
        return .unknown
    }
}
