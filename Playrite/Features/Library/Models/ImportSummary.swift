import Foundation

/// Result of importing a ``LibraryArchive``. Existing items (same identifier) are skipped, never overwritten.
struct ImportSummary: Equatable, Sendable {
    var gamesAdded = 0
    var gamesSkipped = 0
    var seriesAdded = 0
    var collectionsAdded = 0

    /// One-line description for the UI.
    var description: String {
        "Imported \(gamesAdded) games (\(gamesSkipped) already present), "
            + "\(seriesAdded) series, \(collectionsAdded) collections."
    }
}
