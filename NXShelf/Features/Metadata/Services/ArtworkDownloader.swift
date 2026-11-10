import Foundation

/// Downloads candidate images and caches the first real one. A candidate that 404s, errors or isn't an image
/// (an HTML error page, say) is skipped silently; the next candidate is tried.
struct ArtworkDownloader: Sendable {
    /// Most carousel slides cached per game.
    static let carouselLimit = 10
    private static let okLowerBound = 200
    private static let okUpperBound = 300
    private static let success = okLowerBound ..< okUpperBound

    private let http: any HTTPClient
    private let cache: any ArtworkCaching

    /// Creates the downloader.
    init(http: any HTTPClient, cache: any ArtworkCaching) {
        self.http = http
        self.cache = cache
    }

    /// Path of the first candidate that downloads as an image, or `nil`.
    func firstImage(from candidates: [URL], gameID: UUID, kind: ArtworkKind) async -> String? {
        for url in candidates {
            if let path = await download(url, gameID: gameID, kind: kind, index: 0) {
                return path
            }
        }
        return nil
    }

    /// Paths of every candidate that downloads as an image, in order, up to ``carouselLimit``.
    func carousel(from candidates: [URL], gameID: UUID) async -> [String] {
        var paths: [String] = []
        for url in candidates.prefix(Self.carouselLimit) {
            if let path = await download(url, gameID: gameID, kind: .carousel, index: paths.count) {
                paths.append(path)
            }
        }
        return paths
    }

    private func download(_ url: URL, gameID: UUID, kind: ArtworkKind, index: Int) async -> String? {
        guard let (data, response) = try? await http.data(for: URLRequest(url: url)),
              Self.success.contains(response.statusCode),
              let format = ImageFormat.detect(data)
        else { return nil }
        return try? cache.store(data, format: format, gameID: gameID, kind: kind, index: index)
    }
}
