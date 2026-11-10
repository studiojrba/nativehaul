import Foundation

/// Produces a ``LibrarySnapshot``. Live: ``RepositorySnapshotProvider``; mock: ``MockSnapshotProvider``.
@MainActor
protocol LibrarySnapshotProviding: AnyObject {
    /// Takes a snapshot of the current library.
    func snapshot() throws -> LibrarySnapshot
}
