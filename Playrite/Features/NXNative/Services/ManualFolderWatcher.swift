import Foundation

/// Mock ``FolderWatching``: records the watched path; tests call ``fire()`` to simulate a change.
@MainActor
final class ManualFolderWatcher: FolderWatching {
    /// The folder being watched, if any.
    private(set) var watchedPath: String?
    private var onChange: (@MainActor () -> Void)?

    /// Creates the watcher.
    init() {}

    func watch(_ path: String, onChange: @escaping @MainActor () -> Void) {
        watchedPath = path
        self.onChange = onChange
    }

    func stop() {
        watchedPath = nil
        onChange = nil
    }

    /// Simulates a change in the watched folder.
    func fire() {
        onChange?()
    }
}
