import Foundation
import Observation

/// The desktop shell's state (spec §3.0): which screen shows, where Detail was opened from, the top bar's search, the
/// launch overlay and the mode. Views render it; the menu bar drives it too.
@MainActor
@Observable
final class ShellViewModel {
    /// The screen on show.
    private(set) var screen = AppScreen.home
    /// The game Detail shows.
    private(set) var detailGameID: UUID?
    /// Where Detail was opened from (Back returns there).
    private(set) var detailOrigin = AppScreen.home
    /// The title ID Builds should select when it opens (set by Detail's build link), until Builds takes it.
    private(set) var buildsFocusTitleID: String?
    /// Desktop or couch.
    private(set) var mode = AppMode.desktop
    /// The top bar's search text.
    var searchQuery = ""
    /// Bumped to ask the search field to take focus (⌘K).
    private(set) var searchFocusRequest = 0
    /// The game being launched (the launch overlay shows while set).
    private(set) var launchingGame: Game?
    /// A launch failure for the app's error surface.
    var launchError: String?
    /// Add Game sheet.
    var isAddingGame = false
    /// Import Library file picker.
    var isImporting = false
    /// Merge Duplicates sheet.
    var isMergingDuplicates = false
    /// A library export waiting to be saved.
    var exportDocument: LibraryJSONDocument?
    /// The tool sheet on show (Series, Collections, Stats, Playtime Tracking).
    var presentedTool: ToolSheet?

    @ObservationIgnored private let makeLaunch: @MainActor (Game) -> GameLaunchViewModel
    @ObservationIgnored private let isAppActive: @MainActor () -> Bool
    @ObservationIgnored private let onNavigate: @MainActor () -> Void
    @ObservationIgnored private let onBack: @MainActor () -> Void

    /// Creates the shell. `makeLaunch` builds a game's launch view model; `isAppActive` reports whether nativehaul is
    /// still frontmost; `onNavigate` / `onBack` play the shell sounds.
    init(
        makeLaunch: @escaping @MainActor (Game) -> GameLaunchViewModel,
        isAppActive: @escaping @MainActor () -> Bool = { true },
        onNavigate: @escaping @MainActor () -> Void = {},
        onBack: @escaping @MainActor () -> Void = {}
    ) {
        self.makeLaunch = makeLaunch
        self.isAppActive = isAppActive
        self.onNavigate = onNavigate
        self.onBack = onBack
    }

    // MARK: Navigation

    /// Shows `target` (the page starts at the top). Detail needs a game: use ``open(gameID:)``.
    func go(to target: AppScreen) {
        guard target != .detail, target != screen else { return }
        screen = target
        onNavigate()
    }

    /// Opens a game's Detail, remembering where it was opened from.
    func open(gameID: UUID) {
        if screen != .detail {
            detailOrigin = screen
        }
        detailGameID = gameID
        screen = .detail
    }

    /// Opens Builds focused on a title (Detail's build link).
    func openBuilds(focusing titleID: String?) {
        buildsFocusTitleID = titleID
        go(to: .builds)
    }

    /// Builds has selected the focused title.
    func buildsFocusTaken() {
        buildsFocusTitleID = nil
    }

    /// Leaves Detail for the screen it was opened from.
    func back() {
        guard screen == .detail else { return }
        screen = detailOrigin
        onBack()
    }

    /// Detail's game went away (deleted): fall back to where it came from.
    func detailGameDisappeared() {
        guard screen == .detail else { return }
        screen = detailOrigin
    }

    /// The top bar's Couch mode pill, the saved "Open in" choice at launch, or the Go menu: couch takes the window
    /// (ADR 0058). The desktop's own state (screen, Detail, search) is kept for the way back.
    func enterCouch() {
        guard mode != .couch else { return }
        launchingGame = nil
        mode = .couch
    }

    /// Back to the desktop (the controller's View button, couch Settings, or the Go menu).
    func exitCouch() {
        guard mode != .desktop else { return }
        mode = .desktop
    }

    // MARK: Search

    /// The top bar's results for the current query (spec §3.0: at most five).
    func searchResults(in games: [Game]) -> [Game] {
        GameSearch.results(for: searchQuery, in: games)
    }

    /// A result was picked: open it and clear the field.
    func selectSearchResult(_ game: Game) {
        open(gameID: game.id)
        searchQuery = ""
    }

    /// ⌘K: focus the search field from anywhere.
    func requestSearchFocus() {
        searchFocusRequest += 1
    }

    // MARK: Launch

    /// Plays `game` from the shell, by `option` (default: its primary route). Games with no way to launch open their
    /// Detail instead, which says why and offers any missing file. The overlay shows until the handoff completes
    /// (``handoffCompleted()``) or the launch fails.
    func play(_ game: Game, option: LaunchOption? = nil) async {
        let launch = makeLaunch(game)
        guard launch.primaryOption != nil else {
            open(gameID: game.id)
            return
        }
        launchingGame = game
        await launch.launch(option)
        launchFinished(errorMessage: launch.errorMessage)
    }

    /// The launch call returned. A failure dismisses the overlay and goes to the error surface; a success dismisses it
    /// once the game has taken over (now, if nativehaul is already in the background).
    func launchFinished(errorMessage: String?) {
        if let errorMessage {
            launchingGame = nil
            launchError = errorMessage
        } else if launchingGame != nil, !isAppActive() {
            launchingGame = nil
        }
    }

    /// The game took over (nativehaul went to the background or hid for it): the overlay's job is done.
    func handoffCompleted() {
        launchingGame = nil
    }

    /// The user dismissed the overlay (Esc or a click) — the safety valve if a game never comes forward.
    func dismissLaunchOverlay() {
        launchingGame = nil
    }
}
