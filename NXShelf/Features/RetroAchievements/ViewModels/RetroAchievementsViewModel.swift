import Foundation
import Observation

/// The RetroAchievements section on an emulated game's page (ADR 0047). It remembers the matched game ID on the
/// game, so the ROM is hashed once.
@MainActor
@Observable
final class RetroAchievementsViewModel {
    /// What RetroAchievements has, once loaded.
    private(set) var lookup: RetroAchievementsLookup?
    private let game: Game
    private let service: any RetroAchievementsProviding
    private let repository: any LibraryRepository

    /// Creates the view model.
    init(game: Game, service: any RetroAchievementsProviding, repository: any LibraryRepository) {
        self.game = game
        self.service = service
        self.repository = repository
    }

    /// Whether the section shows at all: never without credentials, or for a system NX Shelf can't identify.
    var isShown: Bool {
        switch lookup {
        case .found, .notFound, .failed: true
        case .unavailable, .unsupportedSystem, nil: false
        }
    }

    /// Loads progress for the game's ROM.
    func load() async {
        guard let romPath = game.romPath, let system = game.emulatedSystem else {
            lookup = .unsupportedSystem
            return
        }
        let result = await service.lookup(romPath: romPath, system: system, knownGameID: game.retroAchievementsGameID)
        if case let .found(progress) = result, game.retroAchievementsGameID != progress.gameID {
            game.retroAchievementsGameID = progress.gameID
            try? repository.save()
        }
        lookup = result
    }
}
