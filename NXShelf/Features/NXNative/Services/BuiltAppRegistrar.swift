import Foundation

/// Adds a freshly built app to the library (linking a same-titled game when present) and starts tracking it.
@MainActor
struct BuiltAppRegistrar {
    private let repository: any LibraryRepository
    private let watcher: any PlaytimeWatching

    /// Creates the registrar.
    init(repository: any LibraryRepository, watcher: any PlaytimeWatching) {
        self.repository = repository
        self.watcher = watcher
    }

    /// Registers the app and returns the linked game.
    @discardableResult
    func register(title: String, appPath: String, titleID: String? = nil, version: Int? = nil) throws -> Game {
        let games = try repository.fetchGames()
        let game = games
            .first { $0.title.compare(title, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }
            ?? {
                let newGame = Game(title: title, platform: .switchPort, status: .backlog)
                repository.insert(newGame)
                return newGame
            }()
        game.appBundlePath = BundlePath.normalize(appPath)
        game.switchTitleID = titleID ?? game.switchTitleID
        game.switchVersion = version ?? game.switchVersion
        try repository.save()
        watcher.refreshTrackedApps()
        return game
    }
}
