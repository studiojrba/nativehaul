import AppKit

/// Live ``AppVisibilityControlling`` over `NSApp`. Restoring never activates Retriever, so the user's next app keeps
/// the focus.
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
}
