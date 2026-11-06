import Foundation

/// Mock ``GameFolderImporting`` returning a fixed summary and counting calls.
@MainActor
final class MockGameFolderImporter: GameFolderImporting {
    /// Summary to return.
    var summary = FolderImportSummary(found: 1, added: 1, bottlesFound: 1, crossOverAdded: 1)
    /// Number of scans performed.
    private(set) var scanCount = 0

    /// Creates the mock.
    init() {}

    func scanConfiguredFolders() async throws -> FolderImportSummary {
        scanCount += 1
        return summary
    }
}
