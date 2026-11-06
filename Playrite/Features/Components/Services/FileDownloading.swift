import Foundation

/// Downloads a file to disk. Live: ``URLSessionFileDownloader``; mock: ``MockFileDownloader``.
protocol FileDownloading: Sendable {
    /// Downloads `url` to `destination` (overwriting).
    func download(_ url: URL, to destination: String) async throws
}
