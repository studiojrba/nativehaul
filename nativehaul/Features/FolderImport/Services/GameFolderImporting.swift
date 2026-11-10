import Foundation

/// Scans the game folders, adopting existing builds and ROMs as new games. Live: ``GameFolderImporter``;
/// mock: ``MockGameFolderImporter``.
@MainActor
protocol GameFolderImporting: AnyObject {
    /// Scans every game folder and imports what is new. Idempotent.
    func scanConfiguredFolders() async throws -> FolderImportSummary
}
