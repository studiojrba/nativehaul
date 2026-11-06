import Foundation

/// Mock ``URLOpening`` that records URLs.
@MainActor
final class RecordingURLOpener: URLOpening {
    /// URLs opened so far.
    private(set) var opened: [URL] = []

    /// Creates the mock.
    init() {}

    func open(_ url: URL) {
        opened.append(url)
    }
}
