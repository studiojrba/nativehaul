import Foundation

/// Which tile has the focus: a shelf and a position in it.
struct TVFocus: Equatable, Sendable {
    /// Shelf index.
    var shelf = 0
    /// Position inside the shelf.
    var item = 0
}
