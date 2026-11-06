import Foundation

/// Scans configured game folders and CrossOver, importing new games. Live: ``GameFolderImporter``;
/// mock: ``MockGameFolderImporter``.
@MainActor
protocol GameFolderImporting: AnyObject {
    /// Scans every configured folder plus CrossOver and imports what is new. Idempotent.
    func scanConfiguredFolders() async throws -> FolderImportSummary
}
