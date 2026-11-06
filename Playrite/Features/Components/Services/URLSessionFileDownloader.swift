import Foundation

/// Live ``FileDownloading`` using a URLSession download task (streams to disk; large disk images never sit in memory).
struct URLSessionFileDownloader: FileDownloading {
    private static let okLowerBound = 200
    private static let okUpperBound = 300

    func download(_ url: URL, to destination: String) async throws {
        let (temporary, response) = try await URLSession.shared.download(from: url)
        guard let http = response as? HTTPURLResponse,
              (Self.okLowerBound ..< Self.okUpperBound).contains(http.statusCode)
        else { throw ComponentError.releaseUnavailable }
        // The destination is inside a fresh, uniquely named staging folder, so nothing is ever replaced here.
        try FileManager.default.moveItem(at: temporary, to: URL(fileURLWithPath: destination))
    }
}
