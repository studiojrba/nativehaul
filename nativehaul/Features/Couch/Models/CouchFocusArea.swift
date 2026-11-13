import Foundation

/// Where couch focus is: in the screen's content, or in the nav column on the left (the sidebar's couch equivalent,
/// reached with Left from a screen's first column).
enum CouchFocusArea: Equatable, Sendable {
    /// The screen's own content.
    case content
    /// The nav column.
    case nav
}
