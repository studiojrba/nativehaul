import Foundation

/// Mock ``FileVaultStatusProviding`` returning a fixed status.
struct FixedFileVaultStatus: FileVaultStatusProviding {
    /// The status to report.
    var fixed = FileVaultStatus.on

    func status() async -> FileVaultStatus {
        fixed
    }
}
