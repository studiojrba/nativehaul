import Foundation

/// Remembers inbox items the user dismissed, so they never reappear (ADR 0024). Live:
/// ``UserDefaultsBuildsInboxDismissals``.
@MainActor
protocol BuildsInboxDismissing: AnyObject {
    /// Keys (``DetectedGame/id``) of dismissed items.
    func dismissedKeys() -> Set<String>
    /// Dismisses an item.
    func dismiss(_ key: String)
}
