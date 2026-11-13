import Foundation

/// What couch's screens show, from the real library (ADR 0058).
extension CouchViewModel {
    /// The scale for the current screen.
    var scale: CouchScale {
        CouchScale(size: size)
    }

    /// Couch Home's shelves.
    var shelves: [CouchShelf] {
        CouchShelves.make(from: library.games)
    }

    /// Couch Library's games, A–Z (so letter jumps make sense).
    var libraryGames: [Game] {
        LibrarySort.alphabetical.apply(to: library.games)
    }

    /// Builds' jobs, building first then fresh out.
    var buildJobs: [BuildJob] {
        builds.building + builds.freshOut
    }

    /// Couch Detail's buttons: Play when the game can start, and the favourite.
    var detailActions: [CouchDetailAction] {
        guard let detail, detail.game.id == state.detailGameID else { return [.favorite] }
        return detail.launch.primaryOption != nil ? [.play, .favorite] : [.favorite]
    }

    /// What the focus model needs.
    var context: CouchContext {
        CouchContext(
            heroCount: home.slides.count,
            shelves: shelves,
            visibleCount: scale.visibleTiles,
            library: libraryGames.map(CouchShelves.item),
            libraryColumns: scale.visibleTiles,
            detailActions: detailActions,
            buildCount: buildJobs.count,
            settingsRows: CouchSettingsRow.allCases
        )
    }

    /// The prompt bar for the current focus.
    var promptBar: CouchPromptBar {
        CouchPrompts.bar(for: state, context: context, heroPlayLabel: heroGame.map(home.playLabel(for:)) ?? "Play")
    }

    /// The glyph set (Nintendo when no controller is connected — the design set).
    var glyphFamily: ControllerFamily {
        controllerFamily ?? .nintendo
    }

    /// The status pill's words.
    var controllerStatus: String {
        controllerFamily == nil ? "No controller" : "Controller connected"
    }

    /// The status pill's clock.
    var clockText: String {
        CouchClock.string(from: now)
    }

    /// The game the background wash follows: the launching game, the focused tile, the hero's incoming game, Detail's
    /// game or the selected build.
    var tintGame: Game? {
        if let game = sessionGame {
            return game
        }
        switch state.screen {
        case .home:
            return focusedShelfGame ?? heroTintGame
        case .library:
            return libraryGames[safe: state.libraryIndex]
        case .detail:
            return state.detailGameID.flatMap(library.game(withID:))
        case .builds:
            return buildJobs[safe: state.buildsIndex].flatMap(builds.game(for:))
        case .settings:
            return nil
        }
    }

    /// The focused shelf tile's game, when focus is on a shelf tile.
    var focusedShelfGame: Game? {
        let row = state.home.row
        let shelves = shelves
        guard shelves.indices.contains(row), state.home.columns.indices.contains(row) else { return nil }
        let items = shelves[row].items
        let column = max(0, min(items.count - 1, state.home.columns[row]))
        return items[safe: column].flatMap { library.game(withID: $0.id) }
    }

    /// The palette for `game` (the hero's, or one read for couch; neutral until read).
    func palette(for game: Game) -> GamePalette {
        palettes[game.id] ?? home.palettes[game.id] ?? .neutral
    }

    private var heroTintGame: Game? {
        let slides = home.slides
        return slides.indices.contains(home.carousel.index) ? slides[home.carousel.index].game : nil
    }
}
