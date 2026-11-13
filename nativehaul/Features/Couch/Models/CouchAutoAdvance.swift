import Foundation

/// The couch carousel rule (spec §3.7 ⚠ settled): **no auto-advance while navigating**. The 7s timer runs only while
/// focus sits on the hero, on Home, with nothing over it and more than one game to show; any input restarts the
/// cycle (``CouchAutoAdvanceKey``).
enum CouchAutoAdvance {
    /// Whether the hero may advance by itself in `state`.
    static func isEligible(_ state: CouchFocusState, heroCount: Int) -> Bool {
        state.overlay == .none
            && state.screen == .home
            && state.area == .content
            && state.home.row == CouchHomeFocus.heroRow
            && heroCount > 1
    }
}
