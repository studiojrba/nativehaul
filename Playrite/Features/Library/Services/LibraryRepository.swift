import Foundation
import SwiftData

/// Persistence access for library models. Live: ``SwiftDataLibraryRepository``; mock: ``MockLibraryRepository``.
@MainActor
protocol LibraryRepository: AnyObject {
    /// All games.
    func fetchGames() throws -> [Game]
    /// All series.
    func fetchSeries() throws -> [Series]
    /// All collections.
    func fetchCollections() throws -> [GameCollection]
    /// Inserts a model.
    func insert(_ model: some PersistentModel)
    /// Deletes a model.
    func delete(_ model: some PersistentModel)
    /// Persists pending changes.
    func save() throws
}
