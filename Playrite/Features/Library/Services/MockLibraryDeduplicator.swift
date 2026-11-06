import Foundation

/// Mock ``LibraryDeduplicating`` returning fixed groups.
@MainActor
final class MockLibraryDeduplicator: LibraryDeduplicating {
    /// Groups to report.
    var groups: [DuplicateGroup]
    /// Number of `mergeAll()` calls.
    private(set) var mergeCount = 0

    /// Creates the mock.
    init(groups: [DuplicateGroup] = [DuplicateGroup(
        survivorID: UUID(),
        title: "Tideborn",
        duplicateIDs: [UUID()],
        gains: ["tracked app", "1 session"]
    )]) {
        self.groups = groups
    }

    func findDuplicates() throws -> [DuplicateGroup] {
        groups
    }

    func mergeAll() throws -> Int {
        mergeCount += 1
        let deleted = groups.reduce(0) { $0 + $1.duplicateIDs.count }
        groups = []
        return deleted
    }
}
