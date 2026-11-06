import Foundation
import Observation

/// Collections sidebar screen.
@MainActor
@Observable
final class CollectionsViewModel {
    /// All collections.
    private(set) var collections: [GameCollection] = []
    /// Last error.
    private(set) var errorMessage: String?

    private let repository: any LibraryRepository

    /// Creates the view model.
    init(repository: any LibraryRepository) {
        self.repository = repository
    }

    /// Reloads collections.
    func reload() {
        perform {}
    }

    /// Adds a collection. Blank names are ignored.
    func addCollection(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        perform { repository.insert(GameCollection(name: trimmed)) }
    }

    /// Deletes a collection and its sub-games.
    func delete(_ collection: GameCollection) {
        perform { repository.delete(collection) }
    }

    private func perform(_ change: () -> Void) {
        change()
        do {
            try repository.save()
            collections = try repository.fetchCollections()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
