import Foundation

/// A set of library entries with the same normalised title that will become one entry.
struct DuplicateGroup: Equatable, Hashable, Sendable, Identifiable {
    /// Entry that survives (keeps its identifier and data).
    let survivorID: UUID
    /// Survivor's title.
    let title: String
    /// Entries merged into the survivor and then deleted.
    let duplicateIDs: [UUID]
    /// Plain-language list of what the survivor gains (e.g. "tracked app", "2 sessions").
    let gains: [String]

    /// Identity for lists.
    var id: UUID {
        survivorID
    }

    /// "1 duplicate removed · keeps tracked app, 2 sessions".
    var detail: String {
        let count = duplicateIDs.count
        let removed = count == 1 ? "1 duplicate removed" : "\(count) duplicates removed"
        return gains.isEmpty ? removed : "\(removed) · keeps \(gains.joined(separator: ", "))"
    }
}
