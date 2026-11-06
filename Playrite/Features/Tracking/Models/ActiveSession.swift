import Foundation

/// A tracked game that is running right now.
struct ActiveSession: Equatable, Sendable, Identifiable {
    /// The library game.
    let gameID: UUID
    /// Process identifier of the running instance.
    let processID: Int32
    /// When the process launched (or when tracking first saw it).
    let startedAt: Date

    /// Identity for lists.
    var id: Int32 {
        processID
    }
}
