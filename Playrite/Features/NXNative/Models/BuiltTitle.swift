import Foundation

/// A Switch app already built into the library, used so the inbox doesn't offer it again (ADR 0024).
struct BuiltTitle: Equatable, Sendable {
    /// Its title ID, when recorded.
    let titleID: String?
    /// Its library title.
    let name: String

    /// Whether `item` is this game: same title ID, or the same name when the item has no title ID.
    func matches(_ item: DetectedGame) -> Bool {
        if let titleID, !titleID.isEmpty, !item.titleID.isEmpty {
            return titleID.caseInsensitiveCompare(item.titleID) == .orderedSame
        }
        return name.compare(item.name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }
}
