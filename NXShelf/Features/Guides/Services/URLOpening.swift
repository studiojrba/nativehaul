import Foundation

/// Opens URLs in the user's browser. Live: ``WorkspaceURLOpener``; mock: ``RecordingURLOpener``.
@MainActor
protocol URLOpening: AnyObject {
    /// Opens a URL externally.
    func open(_ url: URL)
}
