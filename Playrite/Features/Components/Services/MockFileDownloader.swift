import Foundation
import Synchronization

/// Mock ``FileDownloading`` writing fixed bytes into a ``FileOperating`` tree. Records URLs.
final class MockFileDownloader: FileDownloading {
    private let files: any FileOperating
    private let body: Data
    private let urls = Mutex<[URL]>([])

    /// Creates the mock.
    init(files: any FileOperating, body: Data = Data("payload".utf8)) {
        self.files = files
        self.body = body
    }

    /// URLs downloaded, in order.
    var downloaded: [URL] {
        urls.withLock { $0 }
    }

    func download(_ url: URL, to destination: String) async throws {
        urls.withLock { $0.append(url) }
        try files.writeData(body, toPath: destination)
    }
}
