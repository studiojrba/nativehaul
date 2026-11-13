import SwiftUI

extension EnvironmentValues {
    /// The enclosing shelf's controller, so cards can swallow the click that ends a drag (spec §4.2).
    @Entry var shelfController: ShelfGlideController?
    /// `true` while the enclosing shelf is being dragged: press transforms are suppressed.
    @Entry var isShelfDragging = false
}
