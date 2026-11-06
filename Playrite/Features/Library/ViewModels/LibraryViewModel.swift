import Foundation
import Observation

/// State and actions for the library grid and sidebar counts.
@MainActor
@Observable
final class LibraryViewModel {
    /// All games, refreshed by ``reload()``.
    private(set) var games: [Game] = []
    /// Active section and search.
    var filter = LibraryFilter()
    /// Last error to surface, if any.
    var errorMessage: String?
    /// Last import result, if any.
    var importSummary: ImportSummary?

    private let repository: any LibraryRepository
    private let transfer: any LibraryTransferring

    /// Creates the view model.
    init(repository: any LibraryRepository, transfer: any LibraryTransferring) {
        self.repository = repository
        self.transfer = transfer
    }

    /// Games after section and search filtering.
    var visibleGames: [Game] {
        filter.apply(to: games)
    }

    /// Number of games in a section.
    func count(for section: LibrarySection) -> Int {
        LibraryFilter(section: section).apply(to: games).count
    }

    /// Looks up a game by identifier.
    func game(withID id: Game.ID) -> Game? {
        games.first { $0.id == id }
    }

    /// Reloads games from the repository.
    func reload() {
        perform { games = try repository.fetchGames() }
    }

    /// Adds a game and reloads. Blank titles are ignored.
    func addGame(title: String, platform: GamePlatform, status: GameStatus) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        perform {
            repository.insert(Game(title: trimmed, platform: platform, status: status))
            try repository.save()
            games = try repository.fetchGames()
        }
    }

    /// Deletes a game and reloads.
    func delete(_ game: Game) {
        perform {
            repository.delete(game)
            try repository.save()
            games = try repository.fetchGames()
        }
    }

    /// Changes a game's status.
    func setStatus(_ status: GameStatus, for game: Game) {
        perform {
            game.updateStatus(status)
            try repository.save()
            games = try repository.fetchGames()
        }
    }

    /// JSON for the whole library, or `nil` after recording an error.
    func exportData() -> Data? {
        var result: Data?
        perform { result = try transfer.exportData() }
        return result
    }

    /// Imports a JSON archive and reloads.
    func importLibrary(from data: Data) {
        perform {
            importSummary = try transfer.importData(data)
            games = try repository.fetchGames()
        }
    }

    private func perform(_ work: () throws -> Void) {
        do {
            try work()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
