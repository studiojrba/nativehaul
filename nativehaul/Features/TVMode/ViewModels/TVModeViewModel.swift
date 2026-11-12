import Foundation
import Observation

/// TV (couch) mode state (ADR 0052): shelves, focus, the detail and menu screens, prompts and launching. Input comes
/// in as ``TVInput`` from a controller or the keyboard, so every rule here is tested without hardware.
@MainActor
@Observable
final class TVModeViewModel {
    /// The library's shelves.
    private(set) var shelves: [TVShelf] = []
    /// The focused tile.
    private(set) var focus = TVFocus()
    /// What is on screen.
    private(set) var screen: TVScreen = .library
    /// The highlighted menu row.
    private(set) var menuIndex = 0
    /// The controller driving TV mode (`.keyboard` when none is connected).
    private(set) var family: ControllerFamily = .keyboard
    /// A short message (why a game can't start, or a refused power action).
    private(set) var message: String?
    /// Grid columns that fit on screen; the view keeps this current.
    var gridColumns = DesignTokens.TVMode.minimumColumns
    /// Called when the user exits TV mode.
    var onExit: @MainActor () -> Void = {}

    private var screenBeforeMenu: TVScreen = .library
    private var audioOutputName: String?
    private let repository: any LibraryRepository
    private let preferences: any TVModePreferencesStoring
    private let power: any PowerActing
    private let audio: any AudioOutputReading
    private let makeLauncher: @MainActor (Game) -> GameLaunchViewModel

    /// Creates the view model.
    init(
        repository: any LibraryRepository,
        preferences: any TVModePreferencesStoring,
        power: any PowerActing,
        audio: any AudioOutputReading,
        makeLauncher: @escaping @MainActor (Game) -> GameLaunchViewModel
    ) {
        self.repository = repository
        self.preferences = preferences
        self.power = power
        self.audio = audio
        self.makeLauncher = makeLauncher
    }

    /// Library layout (shelves or grid), saved in TV mode preferences.
    var layout: TVLayout {
        get {
            access(keyPath: \.layout)
            return preferences.preferences.layout
        }
        set {
            withMutation(keyPath: \.layout) { preferences.preferences.layout = newValue }
            focus = clamped(focus)
        }
    }

    /// The focused game, if the library has any.
    var focusedGame: Game? {
        guard shelves.indices.contains(focus.shelf) else { return nil }
        let games = shelves[focus.shelf].games
        return games.indices.contains(focus.item) ? games[focus.item] : nil
    }

    /// The Start/Options menu rows.
    var menuItems: [TVMenuItem] {
        [
            .layout(layout),
            .audioOutput(audioOutputName),
            .power(.sleep),
            .power(.restart),
            .power(.shutDown),
            .exitTVMode,
        ]
    }

    /// The bottom bar's button prompts for the current screen.
    var prompts: [TVPrompt] {
        switch screen {
        case .library where focusedGame == nil:
            [TVPrompt(action: .menu, label: "Menu")]
        case .library:
            [TVPrompt(action: .confirm, label: "Play"), TVPrompt(action: .details, label: "Details")]
                + (shelves.count > 1 ? [TVPrompt(action: .shelves, label: "Shelves")] : [])
                + [TVPrompt(action: .letters, label: "A–Z"), TVPrompt(action: .menu, label: "Menu")]
        case .detail:
            [
                TVPrompt(action: .confirm, label: "Play"),
                TVPrompt(action: .back, label: "Back"),
                TVPrompt(action: .menu, label: "Menu"),
            ]
        case .menu:
            [TVPrompt(action: .confirm, label: "Select"), TVPrompt(action: .back, label: "Close")]
        case let .confirm(action):
            [TVPrompt(action: .confirm, label: action.title), TVPrompt(action: .back, label: "Cancel")]
        }
    }

    /// Reloads the library into shelves, keeping the focus where it can.
    func reload() {
        shelves = TVShelf.shelves(from: (try? repository.fetchGames()) ?? [])
        focus = clamped(focus)
    }

    /// Records which controller is in use (prompts follow it).
    func setFamily(_ family: ControllerFamily) {
        self.family = family
    }

    /// Handles one command for the current screen.
    func handle(_ input: TVInput) async {
        message = nil
        switch screen {
        case .library: await handleLibrary(input)
        case .detail: await handleDetail(input)
        case .menu: await handleMenu(input)
        case let .confirm(action): await handleConfirm(input, action: action)
        }
    }

    private func handleLibrary(_ input: TVInput) async {
        let counts = shelves.map(\.games.count)
        switch input {
        case let .move(direction):
            focus = TVNavigator.move(focus, direction, shelfCounts: counts, layout: layout, columns: gridColumns)
        case .confirm: await launchFocused()
        case .details where focusedGame != nil: screen = .detail
        case .nextShelf: focus = TVNavigator.changingShelf(focus, by: 1, shelfCounts: counts, keepItem: false)
        case .previousShelf: focus = TVNavigator.changingShelf(focus, by: -1, shelfCounts: counts, keepItem: false)
        case .nextLetter: jumpLetter(TVNavigator.nextLetter)
        case .previousLetter: jumpLetter(TVNavigator.previousLetter)
        case .menu: openMenu()
        case .back, .details: break
        }
    }

    private func handleDetail(_ input: TVInput) async {
        switch input {
        case .confirm: await launchFocused()
        case .back: screen = .library
        case .menu: openMenu()
        case .move, .details, .nextShelf, .previousShelf, .nextLetter, .previousLetter: break
        }
    }

    private func handleMenu(_ input: TVInput) async {
        switch input {
        case .move(.up): menuIndex = max(menuIndex - 1, 0)
        case .move(.down): menuIndex = min(menuIndex + 1, menuItems.count - 1)
        case .confirm: activate(menuItems[menuIndex])
        case .back, .menu: screen = screenBeforeMenu
        case .move, .details, .nextShelf, .previousShelf, .nextLetter, .previousLetter: break
        }
    }

    private func handleConfirm(_ input: TVInput, action: TVPowerAction) async {
        switch input {
        case .confirm:
            do {
                try await power.perform(action)
                screen = .library
            } catch {
                message = error.localizedDescription
                screen = .menu
            }
        case .back, .menu: screen = .menu
        case .move, .details, .nextShelf, .previousShelf, .nextLetter, .previousLetter: break
        }
    }

    private func openMenu() {
        screenBeforeMenu = screen
        audioOutputName = audio.currentOutputName()
        menuIndex = 0
        screen = .menu
    }

    private func activate(_ item: TVMenuItem) {
        switch item {
        case .layout: layout = layout.toggled
        case .audioOutput: break
        case let .power(action): screen = .confirm(action)
        case .exitTVMode:
            screen = .library
            onExit()
        }
    }

    private func jumpLetter(_ rule: (Int, [String]) -> Int?) {
        guard shelves.indices.contains(focus.shelf) else { return }
        if let index = rule(focus.item, shelves[focus.shelf].games.map(\.title)) {
            focus.item = index
        }
    }

    /// Starts the focused game: full screen unless it is marked "Open windowed in TV mode".
    private func launchFocused() async {
        guard let game = focusedGame else { return }
        let launch = makeLauncher(game)
        guard launch.primaryOption != nil else {
            message = launch.unavailableReason ?? "This game needs a file first. Set it up in desktop mode."
            return
        }
        await launch.launch(style: game.launchesWindowedInTVMode ? .windowed : .fullScreen)
        message = launch.errorMessage
    }

    private func clamped(_ focus: TVFocus) -> TVFocus {
        guard !shelves.isEmpty else { return TVFocus() }
        let shelf = min(max(focus.shelf, 0), shelves.count - 1)
        return TVFocus(shelf: shelf, item: min(max(focus.item, 0), shelves[shelf].games.count - 1))
    }
}
