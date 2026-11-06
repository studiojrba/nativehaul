import Foundation
import Observation

/// Shows the Up Next strip of every series a game belongs to, on its detail screen.
@MainActor
@Observable
final class SeriesMembershipViewModel {
    /// The game.
    let game: Game
    private let repository: any LibraryRepository

    /// Creates the view model.
    init(game: Game, repository: any LibraryRepository) {
        self.game = game
        self.repository = repository
    }

    /// Series containing this game directly or via its collection's sub-games.
    var memberships: [(series: Series, upNext: [UpNextItem])] {
        let allSeries = (try? repository.fetchSeries()) ?? []
        return allSeries
            .filter { series in
                series.entries.contains { $0.game?.id == game.id || $0.subGame?.collection?.parentGame?.id == game.id }
            }
            .map { ($0, UpNextEngine.upNext(for: $0)) }
    }
}
