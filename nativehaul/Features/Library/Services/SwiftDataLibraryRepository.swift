import Foundation
import SwiftData

/// ``LibraryRepository`` backed by a SwiftData `ModelContext`.
@MainActor
final class SwiftDataLibraryRepository: LibraryRepository {
    private let context: ModelContext

    /// Creates a repository over the given context.
    init(context: ModelContext) {
        self.context = context
    }

    func fetchGames() throws -> [Game] {
        try context.fetch(FetchDescriptor<Game>(sortBy: [SortDescriptor(\.title)]))
    }

    func fetchSeries() throws -> [Series] {
        try context.fetch(FetchDescriptor<Series>(sortBy: [SortDescriptor(\.name)]))
    }

    func fetchCollections() throws -> [GameCollection] {
        try context.fetch(FetchDescriptor<GameCollection>(sortBy: [SortDescriptor(\.name)]))
    }

    func insert(_ model: some PersistentModel) {
        context.insert(model)
    }

    func delete(_ model: some PersistentModel) {
        context.delete(model)
    }

    func save() throws {
        try context.save()
    }
}
