import Foundation

/// Live ``FolderWatching``: a kernel event source on the folder, debounced so a burst of writes is one change.
/// Read-only: it opens the folder for event notification only.
@MainActor
final class DispatchFolderWatcher: FolderWatching {
    private static let debounceSeconds = 2
    private static let debounce = Duration.seconds(debounceSeconds)
    private var source: (any DispatchSourceFileSystemObject)?
    private var pending: Task<Void, Never>?

    /// Creates the watcher.
    init() {}

    func watch(_ path: String, onChange: @escaping @MainActor () -> Void) {
        stop()
        let descriptor = open(path, O_EVTONLY)
        guard descriptor >= 0 else { return }
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .rename, .delete, .extend],
            queue: .main
        )
        source.setEventHandler { [weak self] in
            MainActor.assumeIsolated { self?.schedule(onChange) }
        }
        source.setCancelHandler { close(descriptor) }
        source.resume()
        self.source = source
    }

    func stop() {
        pending?.cancel()
        source?.cancel()
        source = nil
    }

    private func schedule(_ onChange: @escaping @MainActor () -> Void) {
        pending?.cancel()
        pending = Task {
            try? await Task.sleep(for: Self.debounce)
            guard !Task.isCancelled else { return }
            onChange()
        }
    }
}
