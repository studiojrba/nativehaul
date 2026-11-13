import Foundation

/// The contextual prompt bar (spec §3.7, ADR 0058): it follows the focused screen, row and overlay. Right group:
/// − Desktop and + Settings everywhere (Home on Home only says "Already home", so it isn't advertised there).
enum CouchPrompts {
    /// The bar for `state`. `heroPlayLabel` is the hero's "Keep playing" / "Play".
    static func bar(
        for state: CouchFocusState,
        context: CouchContext,
        heroPlayLabel: String = "Play"
    ) -> CouchPromptBar {
        switch state.overlay {
        case .none:
            break
        case .message:
            return CouchPromptBar(leading: [CouchPrompt(buttons: [.select], label: "OK")])
        case .launching:
            return CouchPromptBar(leading: [CouchPrompt(buttons: [.back], label: "Back to the shelf")])
        case .paused, .closing, .forceQuitOffer:
            return CouchPromptBar()
        }
        let trailing = [
            CouchPrompt(buttons: [.view], label: "Desktop"),
            CouchPrompt(buttons: [.menu], label: "Settings"),
        ]
        if state.area == .nav {
            return CouchPromptBar(leading: [open, back], trailing: trailing)
        }
        return CouchPromptBar(
            leading: content(state, context: context, heroPlayLabel: heroPlayLabel),
            trailing: trailing
        )
    }

    private static let open = CouchPrompt(buttons: [.select], label: "Open")
    private static let back = CouchPrompt(buttons: [.back], label: "Back")
    private static let about = CouchPrompt(buttons: [.details], label: "About")
    private static let switchGame = CouchPrompt(buttons: [.previousGame, .nextGame], label: "Switch game")
    private static let jumpLetter = CouchPrompt(buttons: [.previousLetter, .nextLetter], label: "Jump letter")

    private static func content(
        _ state: CouchFocusState,
        context: CouchContext,
        heroPlayLabel: String
    ) -> [CouchPrompt] {
        switch state.screen {
        case .home: home(state, context: context, heroPlayLabel: heroPlayLabel)
        case .library: context.library.isEmpty ? [back] : [play, about, jumpLetter, back]
        case .detail: detail(state, context: context)
        case .builds: context.buildCount > 0 ? [CouchPrompt(buttons: [.select], label: "Open game"), back] : [back]
        case .settings: settings(state, context: context)
        }
    }

    private static let play = CouchPrompt(buttons: [.select], label: "Play")

    private static func home(_ state: CouchFocusState, context: CouchContext, heroPlayLabel: String) -> [CouchPrompt] {
        let switcher = context.heroCount > 1 ? [switchGame] : []
        switch state.home.row {
        case CouchHomeFocus.heroArrowsRow:
            let label = state.home.heroArrow == .left ? "Previous game" : "Next game"
            return [CouchPrompt(buttons: [.select], label: label)] + switcher
        case CouchHomeFocus.heroRow:
            guard context.heroCount > 0 else { return [] }
            return [CouchPrompt(buttons: [.select], label: heroPlayLabel), about] + switcher
        default:
            let row = state.home.row
            guard context.shelves.indices.contains(row),
                  state.home.columns.indices.contains(row) else { return switcher }
            let column = state.home.columns[row]
            if column < 0 || column >= context.shelves[row].items.count {
                return [CouchPrompt(buttons: [.select], label: "Scroll")] + switcher
            }
            return [play, about] + switcher + [jumpLetter]
        }
    }

    private static func detail(_ state: CouchFocusState, context: CouchContext) -> [CouchPrompt] {
        let actions = context.detailActions
        guard actions.indices.contains(state.detailIndex) else { return [back] }
        let label = actions[state.detailIndex] == .play ? "Play" : "Favourite"
        return [CouchPrompt(buttons: [.select], label: label), back]
    }

    private static func settings(_ state: CouchFocusState, context: CouchContext) -> [CouchPrompt] {
        let rows = context.settingsRows
        guard rows.indices.contains(state.settingsIndex) else { return [back] }
        let label = rows[state.settingsIndex] == .exitToDesktop ? "Exit to desktop" : "Change"
        return [CouchPrompt(buttons: [.select], label: label), back]
    }
}
