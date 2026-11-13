import Foundation

/// One couch Home shelf (spec §3.7): a title and its games, in order.
struct CouchShelf: Equatable, Sendable, Identifiable {
    /// "Continue playing", "Everything, A–Z".
    let title: String
    /// The games on it.
    let items: [CouchItem]

    /// Shelves are told apart by title.
    var id: String {
        title
    }
}
