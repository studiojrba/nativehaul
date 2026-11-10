import Foundation

/// On-disk store for downloaded artwork, keyed by game ID and kind. Views render from the returned path; nothing is
/// hotlinked and nothing is bundled.
protocol ArtworkCaching: Sendable {
    /// Writes `data` for the game's artwork kind (`index` orders carousel slides) and returns the absolute path.
    func store(_ data: Data, format: ImageFormat, gameID: UUID, kind: ArtworkKind, index: Int) throws -> String
}
