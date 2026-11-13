import Foundation

/// Everything about where couch focus is (spec §3.7, ADR 0058): the screen, the nav column, each screen's remembered
/// focus and the overlay. Pure data; ``CouchNavigator`` moves it.
struct CouchFocusState: Equatable, Sendable {
    /// The screen on show.
    var screen = AppScreen.home
    /// The game couch Detail shows.
    var detailGameID: UUID?
    /// Where couch Detail was opened from (B returns there).
    var detailOrigin = AppScreen.home
    /// Content or the nav column.
    var area = CouchFocusArea.content
    /// The nav column's highlighted item.
    var navIndex = 0
    /// Couch Home's focus.
    var home = CouchHomeFocus()
    /// Couch Library's focused tile.
    var libraryIndex = 0
    /// Couch Detail's focused button.
    var detailIndex = 0
    /// Couch Builds' focused job.
    var buildsIndex = 0
    /// Couch Settings' focused row.
    var settingsIndex = 0
    /// What covers the screen.
    var overlay = CouchOverlay.none

    /// The nav column's items (the nav island's, in order).
    static let navItems = NavItem.allCases

    /// The nav item that lights for the current screen (Detail counts as Library, like the desktop island).
    var navScreenIndex: Int {
        Self.navItems.firstIndex { $0.screen == screen.islandScreen } ?? 0
    }
}
