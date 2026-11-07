import Foundation

/// Tells the builds inbox when a folder's contents change (ADR 0024). Live: ``DispatchFolderWatcher``.
@MainActor
protocol FolderWatching: AnyObject {
    /// Watches `path` (replacing any earlier watch) and calls `onChange` after its contents change.
    func watch(_ path: String, onChange: @escaping @MainActor () -> Void)
    /// Stops watching.
    func stop()
}
