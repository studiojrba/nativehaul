import Foundation

/// Outcome of one scan of the game folders.
struct FolderImportSummary: Equatable, Sendable {
    /// Candidates discovered (app bundles and ROM files).
    var found = 0
    /// New games created from app bundles (existing nxnative builds included).
    var added = 0
    /// Existing games without a bundle path that were linked to a discovered bundle.
    var linked = 0
    /// Candidates already in the library (same bundle or ROM path).
    var skipped = 0
    /// New emulated games created from ROM files.
    var romsAdded = 0
    /// Duplicate entries (same normalised title) merged away after the scan.
    var duplicatesMerged = 0
    /// Folders that were missing or unreadable.
    var unreadableFolders: [String] = []

    /// One-line description for alerts.
    var description: String {
        var text = "Found \(found) · added \(added) · linked \(linked) · skipped \(skipped)."
        if romsAdded > 0 {
            text += " ROMs: \(romsAdded) added."
        }
        if duplicatesMerged > 0 {
            text += " Merged \(duplicatesMerged) duplicates."
        }
        if !unreadableFolders.isEmpty {
            text += " Could not read: \(unreadableFolders.joined(separator: ", "))."
        }
        return text
    }
}
