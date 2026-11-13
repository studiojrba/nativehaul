import AppKit

/// Live ``AppVisibilityControlling`` over `NSApp`. Desktop restoring never activates nativehaul, so the user's next app
/// keeps the focus; couch restoring (``unhide()``) brings the couch screen back in front once the game has exited, so
/// the controller reaches it (ADR 0058).
@MainActor
final class ApplicationVisibility: AppVisibilityControlling {
    /// Creates the controller.
    init() {}

    func hide() {
        NSApp.hide(nil)
    }

    func unhideWithoutActivation() {
        NSApp.unhideWithoutActivation()
    }

    func unhide() {
        NSApp.unhide(nil)
    }
}
