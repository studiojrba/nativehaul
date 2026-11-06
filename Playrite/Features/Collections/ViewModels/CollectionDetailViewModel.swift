import Foundation
import Observation

/// Editing a collection's ordered sub-games, each with its own status.
@MainActor
@Observable
final class CollectionDetailViewModel {
    /// The collection.
    let collection: GameCollection
    /// Last error.
    private(set) var errorMessage: String?

    private let repository: any LibraryRepository

    /// Creates the view model.
    init(collection: GameCollection, repository: any LibraryRepository) {
        self.collection = collection
        self.repository = repository
    }

    /// Sub-games in order.
    var subGames: [SubGame] {
        collection.orderedSubGames
    }

    /// Library games that can be the collection's parent entry.
    var parentCandidates: [Game] {
        (try? repository.fetchGames()) ?? []
    }

    /// The library game this collection ships as.
    var parentGameID: UUID? {
        get { collection.parentGame?.id }
        set { perform { collection.parentGame = parentCandidates.first { $0.id == newValue } } }
    }

    /// Appends a sub-game. Blank titles are ignored.
    func addSubGame(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        perform {
            let subGame = SubGame(
                title: trimmed,
                position: OrderedPositions.nextPosition(after: collection.subGames.map(\.position))
            )
            repository.insert(subGame)
            subGame.collection = collection
        }
    }

    /// Sets one sub-game's status independently of the others.
    func setStatus(_ status: GameStatus, for subGame: SubGame) {
        perform { subGame.status = status }
    }

    /// Reorders sub-games.
    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        perform {
            OrderedPositions.renumber(OrderedPositions.moved(subGames, fromOffsets: source, toOffset: destination)) {
                $0.position = $1
            }
        }
    }

    /// Removes sub-games at offsets.
    func remove(atOffsets offsets: IndexSet) {
        let current = subGames
        perform { offsets.map { current[$0] }.forEach(repository.delete) }
    }

    private func perform(_ change: () -> Void) {
        change()
        do {
            try repository.save()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
