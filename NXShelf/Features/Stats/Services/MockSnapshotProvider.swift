import Foundation

/// Mock ``LibrarySnapshotProviding`` returning a fixed snapshot.
@MainActor
final class MockSnapshotProvider: LibrarySnapshotProviding {
    /// Snapshot to return.
    var value: LibrarySnapshot

    /// Creates the mock.
    init(_ value: LibrarySnapshot = .empty) {
        self.value = value
    }

    func snapshot() throws -> LibrarySnapshot {
        value
    }
}
