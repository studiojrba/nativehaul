import Foundation

/// Outcome of one "Scan Game Folders" run. CrossOver figures are reported separately.
struct FolderImportSummary: Equatable, Sendable {
    /// Candidates discovered (app bundles, CrossOver launchers and bottle installs).
    var found = 0
    /// New games created from app bundles in the configured folders.
    var added = 0
    /// Existing games without a bundle path that were linked to a discovered bundle.
    var linked = 0
    /// Candidates already in the library (same bundle path, or same title for bottle installs).
    var skipped = 0
    /// CrossOver bottles found.
    var bottlesFound = 0
    /// New games created from CrossOver launchers and bottle installs.
    var crossOverAdded = 0
    /// Configured folders that were missing or unreadable.
    var unreadableFolders: [String] = []

    /// One-line description for alerts.
    var description: String {
        var text = "Found \(found) · added \(added) · linked \(linked) · skipped \(skipped). "
            + "CrossOver: \(bottlesFound) bottles, \(crossOverAdded) games added."
        if !unreadableFolders.isEmpty {
            text += " Could not read: \(unreadableFolders.joined(separator: ", "))."
        }
        return text
    }
}
