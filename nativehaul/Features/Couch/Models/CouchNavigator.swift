import Foundation

/// The couch focus model (spec §3.7, ADR 0058) as a pure state machine: an input moves ``CouchFocusState`` and returns
/// the ``CouchEffect``s for the app to carry out. No UI, no services, no time — so every rule is unit-tested.
///
/// Order of precedence: an overlay takes every input; then the buttons that work everywhere (View, Menu, Home); then
/// the nav column if it has focus; then the screen.
enum CouchNavigator {
    /// Applies `input` to `state` and returns what the app should do.
    static func reduce(_ state: inout CouchFocusState, _ input: CouchInput, context: CouchContext) -> [CouchEffect] {
        if state.overlay != .none {
            return reduceOverlay(&state, input)
        }
        if let effects = reduceGlobal(&state, input) {
            return effects
        }
        if state.area == .nav {
            return reduceNav(&state, input)
        }
        switch state.screen {
        case .home: return reduceHome(&state, input, context: context)
        case .library: return reduceLibrary(&state, input, context: context)
        case .detail: return reduceDetail(&state, input, context: context)
        case .builds: return reduceBuilds(&state, input, context: context)
        case .settings: return reduceSettings(&state, input, context: context)
        }
    }

    /// Opens a game's couch Detail from the current screen.
    static func openDetail(_ state: inout CouchFocusState, gameID: UUID) {
        if state.screen != .detail {
            state.detailOrigin = state.screen
        }
        state.detailGameID = gameID
        state.screen = .detail
        state.detailIndex = 0
        state.area = .content
    }

    /// View, Menu and Home work the same on every screen; `nil` for every other input.
    private static func reduceGlobal(_ state: inout CouchFocusState, _ input: CouchInput) -> [CouchEffect]? {
        switch input {
        case .view:
            return [.sound(.back), .exitToDesktop]
        case .menu:
            return go(&state, to: .settings)
        case .home:
            if state.screen == .home {
                state.area = .content
                return [.toast(.alreadyHome)]
            }
            return goHome(&state)
        default:
            return nil
        }
    }

    // MARK: Shared moves

    /// Shows `screen` with focus in its content.
    static func go(_ state: inout CouchFocusState, to screen: AppScreen) -> [CouchEffect] {
        state.area = .content
        guard screen != state.screen else { return [] }
        state.screen = screen
        return [.sound(.navigate)]
    }

    /// Shows Home with focus in its content.
    static func goHome(_ state: inout CouchFocusState) -> [CouchEffect] {
        state.area = .content
        state.screen = .home
        return [.sound(.back)]
    }

    /// B on a screen other than Home: Detail goes back where it came from, the rest go Home.
    static func back(_ state: inout CouchFocusState) -> [CouchEffect] {
        if state.screen == .detail {
            state.screen = state.detailOrigin
            state.area = .content
            return [.sound(.back)]
        }
        return goHome(&state)
    }

    /// Moves focus to the nav column, on the current screen's item.
    static func focusNav(_ state: inout CouchFocusState) -> [CouchEffect] {
        state.area = .nav
        state.navIndex = state.navScreenIndex
        return [.sound(.navigate)]
    }

    // MARK: Nav column

    private static func reduceNav(_ state: inout CouchFocusState, _ input: CouchInput) -> [CouchEffect] {
        let items = CouchFocusState.navItems
        switch input {
        case .move(.up):
            guard state.navIndex > 0 else { return [] }
            state.navIndex -= 1
            return [.sound(.navigate)]
        case .move(.down):
            guard state.navIndex < items.count - 1 else { return [] }
            state.navIndex += 1
            return [.sound(.navigate)]
        case .move(.right):
            state.area = .content
            return [.sound(.navigate)]
        case .back:
            state.area = .content
            return [.sound(.back)]
        case .select:
            _ = go(&state, to: items[state.navIndex].screen)
            return [.sound(.confirm)]
        default:
            return []
        }
    }

    // MARK: Overlays

    private static func reduceOverlay(_ state: inout CouchFocusState, _ input: CouchInput) -> [CouchEffect] {
        switch state.overlay {
        case .none, .closing:
            return []
        case .launching:
            guard input == .back else { return [] }
            state.overlay = .none
            return [.sound(.back), .dismissLaunch]
        case .message:
            guard input == .select || input == .back else { return [] }
            state.overlay = .none
            return [.sound(input == .select ? .confirm : .back)]
        case let .paused(choice):
            return reducePaused(&state, input, choice: choice)
        case let .forceQuitOffer(choice):
            return reduceForceQuit(&state, input, choice: choice)
        }
    }

    private static func reducePaused(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        choice: PausedChoice
    ) -> [CouchEffect] {
        switch input {
        case .move:
            state.overlay = .paused(choice.toggled)
            return [.sound(.navigate)]
        case .select where choice == .resume, .back, .home:
            state.overlay = .none
            return [.sound(.confirm), .resumeGame]
        case .select:
            state.overlay = .closing
            return [.sound(.confirm), .closeGame]
        default:
            return []
        }
    }

    private static func reduceForceQuit(
        _ state: inout CouchFocusState,
        _ input: CouchInput,
        choice: ForceQuitChoice
    ) -> [CouchEffect] {
        switch input {
        case .move:
            state.overlay = .forceQuitOffer(choice.toggled)
            return [.sound(.navigate)]
        case .select where choice == .forceQuit:
            state.overlay = .closing
            return [.sound(.confirm), .forceQuitGame]
        case .select, .back:
            state.overlay = .closing
            return [.sound(input == .back ? .back : .confirm), .keepWaiting]
        default:
            return []
        }
    }
}
