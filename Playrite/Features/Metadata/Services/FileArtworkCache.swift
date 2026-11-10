import Foundation

/// Live ``ArtworkCaching`` under `~/Library/Application Support/Playrite/Artwork/<game-id>/`.
///
/// Files are named `cover.jpg`, `hero.png`, `carousel-01.jpg`, … and overwritten in place on refresh.
struct FileArtworkCache: ArtworkCaching {
    private let root: URL

    /// Creates a cache rooted at `root`.
    init(root: URL = FileArtworkCache.defaultRoot()) {
        self.root = root
    }

    /// `~/Library/Application Support/Playrite/Artwork`.
    static func defaultRoot() -> URL {
        URL.applicationSupportDirectory.appending(path: "Playrite/Artwork", directoryHint: .isDirectory)
    }

    func store(_ data: Data, format: ImageFormat, gameID: UUID, kind: ArtworkKind, index: Int) throws -> String {
        let folder = root.appending(path: gameID.uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let file = folder.appending(path: Self.fileName(kind: kind, index: index, format: format))
        try data.write(to: file, options: .atomic)
        return file.path(percentEncoded: false)
    }

    /// File name for an artwork slot.
    static func fileName(kind: ArtworkKind, index: Int, format: ImageFormat) -> String {
        switch kind {
        case .cover, .hero, .trailerPoster: "\(kind.rawValue).\(format.fileExtension)"
        case .carousel: "\(kind.rawValue)-\(String(format: "%02d", index + 1)).\(format.fileExtension)"
        }
    }
}
