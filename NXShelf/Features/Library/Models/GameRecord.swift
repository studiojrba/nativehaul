import Foundation

/// Archive form of a ``Game``.
struct GameRecord: Codable, Equatable, Sendable {
    var id: UUID
    var title: String
    var platform: GamePlatform
    var status: GameStatus
    var summary: String
    var releaseDate: Date?
    var addedAt: Date
    var completedAt: Date?
    var lastPlayedAt: Date?
    var coverImagePath: String?
    var appBundlePath: String?
    var selfReportedSeconds: Int?
    /// Optional; older archives omit it.
    var hltbID: Int?
    /// Optional metadata; older archives omit these.
    var developer: String?
    var genres: [String]?
    var tags: [String]?
    var heroImagePath: String?
    /// Optional; older archives omit these.
    var carouselImagePaths: [String]?
    /// Optional; older archives omit these.
    var trailerVideoURL: String?
    var trailerPosterPath: String?
    var metadataSources: [String]?
    var romPath: String?
    var switchTitleID: String?
    var switchVersion: Int?
    var emulatedSystem: String?
    var sessions: [SessionRecord]
    var guides: [GuideRecord]?
}
