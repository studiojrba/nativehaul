import Foundation

/// Portable, versioned JSON representation of the whole library.
struct LibraryArchive: Codable, Equatable, Sendable {
    /// Current archive format version written by this build.
    static let currentFormatVersion = 1

    /// Format version of this archive.
    var formatVersion: Int
    /// When the archive was produced.
    var exportedAt: Date
    /// All games, with their sessions.
    var games: [GameRecord]
    /// All series.
    var series: [SeriesRecord]
    /// All collections.
    var collections: [CollectionRecord]
}
