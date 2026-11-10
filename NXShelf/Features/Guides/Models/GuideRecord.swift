import Foundation

/// Archive form of a ``GuideLink`` (link and attribution only — no guide content exists to export).
struct GuideRecord: Codable, Equatable, Sendable {
    var id: UUID
    var title: String
    var author: String
    var url: String
    var chapters: [GuideChapter]
    var currentChapterID: UUID?
    var addedAt: Date
}
