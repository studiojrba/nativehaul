import Foundation

/// Finds and merges duplicate games (same normalised title). Live: ``LibraryDeduplicator``;
/// mock: ``MockLibraryDeduplicator``.
@MainActor
protocol LibraryDeduplicating: AnyObject {
    /// Groups that would be merged, without changing anything.
    func findDuplicates() throws -> [DuplicateGroup]
    /// Merges every group (deleting the duplicates) and saves. Returns the number of entries deleted.
    @discardableResult
    func mergeAll() throws -> Int
}
