import Foundation

/// What the couch focus model needs to know about the screens it moves over: the shelves, how many tiles fit, the
/// grid, Detail's buttons, the Builds list and the Settings rows. Built by the view model from real data.
struct CouchContext: Equatable, Sendable {
    /// The hero's slide count.
    var heroCount = 0
    /// Couch Home's shelves.
    var shelves: [CouchShelf] = []
    /// Tiles fully visible on a shelf (V, spec §3.7).
    var visibleCount = 1
    /// Couch Library's games, A–Z.
    var library: [CouchItem] = []
    /// Couch Library's grid columns.
    var libraryColumns = 1
    /// Couch Detail's buttons.
    var detailActions: [CouchDetailAction] = [.favorite]
    /// Couch Builds' job count.
    var buildCount = 0
    /// Couch Settings' rows.
    var settingsRows = CouchSettingsRow.allCases
}
