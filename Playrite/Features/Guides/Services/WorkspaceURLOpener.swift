import AppKit

/// Live ``URLOpening`` via `NSWorkspace` (opens the default browser; nothing is loaded inside Retriever).
@MainActor
final class WorkspaceURLOpener: URLOpening {
    /// Creates the opener.
    init() {}

    func open(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
