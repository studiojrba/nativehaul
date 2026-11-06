import Foundation
import SwiftData

/// In-memory ``LibraryRepository`` for previews and tests, optionally seeded with ``SampleLibrary``.
@MainActor
final class MockLibraryRepository: LibraryRepository {
    /// The in-memory container (exposed so previews can attach it to the view hierarchy).
    let container: ModelContainer
    private let live: SwiftDataLibraryRepository
    /// Number of times ``save()`` was called.
    private(set) var saveCount = 0

    /// Creates an empty or seeded in-memory repository.
    init(seeded: Bool = false) throws {
        container = try ModelContainerFactory.make(inMemory: true)
        live = SwiftDataLibraryRepository(context: container.mainContext)
        if seeded {
            SampleLibrary.populate(live)
            try live.save()
        }
    }

    func fetchGames() throws -> [Game] {
        try live.fetchGames()
    }

    func fetchSeries() throws -> [Series] {
        try live.fetchSeries()
    }

    func fetchCollections() throws -> [GameCollection] {
        try live.fetchCollections()
    }

    func insert(_ model: some PersistentModel) {
        live.insert(model)
    }

    func delete(_ model: some PersistentModel) {
        live.delete(model)
    }

    func save() throws {
        saveCount += 1
        try live.save()
    }
}
