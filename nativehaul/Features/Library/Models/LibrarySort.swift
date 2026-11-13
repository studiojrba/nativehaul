import Foundation

/// The Library page's sort orders (spec §3.2).
enum LibrarySort: String, CaseIterable, Identifiable, Sendable {
    /// Most recently played first; never-played games last, by title.
    case recentlyPlayed
    /// Title ascending, ignoring a leading "The ".
    case alphabetical
    /// Biggest single-source playtime first (sources never summed).
    case mostPlayed

    /// The article ignored when sorting A–Z.
    static let ignoredArticle = "the "

    /// Stable identity.
    var id: String {
        rawValue
    }

    /// The segment's label.
    var title: String {
        switch self {
        case .recentlyPlayed: "Recently played"
        case .alphabetical: "A–Z"
        case .mostPlayed: "Most played"
        }
    }

    /// `games` in this order. Ties fall back to A–Z.
    func apply(to games: [Game]) -> [Game] {
        switch self {
        case .recentlyPlayed:
            games.sorted { lhs, rhs in
                switch (lhs.lastPlayedDate, rhs.lastPlayedDate) {
                case let (left?, right?) where left != right: left > right
                case (.some, nil): true
                case (nil, .some): false
                default: Self.alphabeticallyAscending(lhs.title, rhs.title)
                }
            }
        case .alphabetical:
            games.sorted { Self.alphabeticallyAscending($0.title, $1.title) }
        case .mostPlayed:
            games.sorted { lhs, rhs in
                let left = lhs.biggestRealPlaytimeSeconds
                let right = rhs.biggestRealPlaytimeSeconds
                return left == right ? Self.alphabeticallyAscending(lhs.title, rhs.title) : left > right
            }
        }
    }

    /// The key a title sorts by: without a leading "The ".
    static func sortKey(for title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard trimmed.lowercased().hasPrefix(ignoredArticle), trimmed.count > ignoredArticle.count else {
            return trimmed
        }
        return String(trimmed.dropFirst(ignoredArticle.count))
    }

    /// `true` when `lhs` sorts before `rhs` A–Z (leading "The " ignored, Finder-style comparison).
    static func alphabeticallyAscending(_ lhs: String, _ rhs: String) -> Bool {
        sortKey(for: lhs).localizedStandardCompare(sortKey(for: rhs)) == .orderedAscending
    }
}
