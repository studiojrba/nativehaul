import Foundation

/// Outcome of a Steam library sync.
struct SteamSyncSummary: Equatable, Sendable {
    /// Games newly added to the library.
    var added = 0
    /// Existing games whose SteamSynced playtime was updated.
    var updated = 0
    /// When the sync finished.
    var finishedAt: Date

    /// One-line description.
    var description: String {
        "Steam sync: \(added) added, \(updated) updated."
    }
}
