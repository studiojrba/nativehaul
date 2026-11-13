import Foundation

/// The curated shelves Home can show, in page order (Make `Home.tsx`). "Highest rated" is not among them: nothing in
/// the library records a rating, and scores are never invented (logged for J.R in the 0.1.1 report).
enum HomeShelfKind: String, CaseIterable, Sendable {
    /// Games that share a genre with what's being played.
    case suggestions
    /// Added in the last few weeks.
    case fresh
    /// Gentle genres.
    case cosy
    /// Games tagged for more than one player.
    case friends
    /// Released in the last two years.
    case brandNew
    /// Never played.
    case notStarted

    /// The eyebrow.
    var eyebrow: String {
        switch self {
        case .suggestions: "Suggestions for you"
        case .fresh: "Fresh on your shelf"
        case .cosy: "Cosy for tonight"
        case .friends: "Bring a friend"
        case .brandNew: "Brand new"
        case .notStarted: "Not started yet"
        }
    }

    /// The display title.
    var title: String {
        switch self {
        case .suggestions: "A few that fit the mood"
        case .fresh: "New arrivals, ready to play"
        case .cosy: "Slow games, warm drinks"
        case .friends: "Pass the other controller"
        case .brandNew: "Fresh releases, still warm"
        case .notStarted: "Waiting for a first night"
        }
    }

    /// The panel's wash.
    var wash: WashSlot {
        switch self {
        case .suggestions, .brandNew: .blush
        case .fresh: .mint
        case .cosy: .butter
        case .friends: .sky
        case .notStarted: .lilac
        }
    }
}
