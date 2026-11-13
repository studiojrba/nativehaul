import Foundation

/// Mock ``AppVisibilityControlling`` that records calls, for tests and previews.
@MainActor
final class MockAppVisibility: AppVisibilityControlling {
    /// Calls in order: "hide", "unhide" or "unhide-active".
    private(set) var calls: [String] = []

    /// Creates the mock.
    init() {}

    func hide() {
        calls.append("hide")
    }

    func unhideWithoutActivation() {
        calls.append("unhide")
    }

    func unhide() {
        calls.append("unhide-active")
    }
}
