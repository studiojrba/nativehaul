import Foundation
import Observation

/// "Merge Duplicate Games": previews same-titled entries, then merges them on confirmation.
@MainActor
@Observable
final class MergeDuplicatesViewModel {
    /// Groups that will be merged.
    private(set) var groups: [DuplicateGroup] = []
    /// Entries deleted by the last merge, if one ran.
    private(set) var deletedCount: Int?
    /// Last error.
    private(set) var errorMessage: String?

    private let deduplicator: any LibraryDeduplicating
    private let onLibraryChanged: @MainActor () -> Void

    /// Creates the view model.
    init(deduplicator: any LibraryDeduplicating, onLibraryChanged: @escaping @MainActor () -> Void = {}) {
        self.deduplicator = deduplicator
        self.onLibraryChanged = onLibraryChanged
    }

    /// Number of entries that will be deleted.
    var pendingDeletions: Int {
        groups.reduce(0) { $0 + $1.duplicateIDs.count }
    }

    /// Recomputes the preview.
    func refresh() {
        do {
            groups = try deduplicator.findDuplicates()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Merges every previewed group and deletes the duplicates.
    func mergeAll() {
        do {
            deletedCount = try deduplicator.mergeAll()
            groups = []
            errorMessage = nil
            onLibraryChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
