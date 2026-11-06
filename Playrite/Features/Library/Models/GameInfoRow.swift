import Foundation

/// One label/value line in the details info list.
struct GameInfoRow: Equatable, Hashable, Sendable, Identifiable {
    /// Label ("Status", "Time Played", …).
    let label: String
    /// Display value; "—" when unknown.
    let value: String

    /// Identity.
    var id: String {
        label
    }
}
