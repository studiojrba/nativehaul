import Foundation

/// Result of importing a ``LibraryArchive``. Existing items (same identifier) are skipped, never overwritten.
struct ImportSummary: Equatable, Sendable {
    var gamesAdded = 0
    var gamesSkipped = 0
    var seriesAdded = 0
    var collectionsAdded = 0
    /// Duplicate entries (same normalised title) merged away after the import.
    var duplicatesMerged = 0

    /// One-line description for the UI.
    var description: String {
        "Imported \(gamesAdded) games (\(gamesSkipped) already present), "
            + "\(seriesAdded) series, \(collectionsAdded) collections"
            + (duplicatesMerged > 0 ? "; merged \(duplicatesMerged) duplicates." : ".")
    }
}
