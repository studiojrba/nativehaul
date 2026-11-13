import Foundation

/// A game as the couch focus model sees it: its identity and the title letter jumps read.
struct CouchItem: Equatable, Sendable, Identifiable {
    /// The game's identity.
    let id: UUID
    /// Its title.
    let title: String
}
