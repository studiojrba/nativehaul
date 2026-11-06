import Foundation
import Synchronization

/// Mock ``ArtworkCaching`` that keeps bytes in memory and returns fake paths. Records every write.
final class InMemoryArtworkCache: ArtworkCaching {
    /// One recorded write.
    struct Entry: Equatable, Sendable {
        /// Game.
        let gameID: UUID
        /// Kind.
        let kind: ArtworkKind
        /// Fake path returned.
        let path: String
    }

    private let entries = Mutex<[Entry]>([])

    /// Creates an empty cache.
    init() {}

    /// Writes so far, in order.
    var stored: [Entry] {
        entries.withLock { $0 }
    }

    func store(_: Data, format: ImageFormat, gameID: UUID, kind: ArtworkKind, index: Int) throws -> String {
        let path = "/cache/\(gameID.uuidString)/" + FileArtworkCache.fileName(kind: kind, index: index, format: format)
        entries.withLock { $0.append(Entry(gameID: gameID, kind: kind, path: path)) }
        return path
    }
}
