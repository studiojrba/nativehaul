import Foundation

/// A chapter/page of an external guide. Stores only a title and a link — never guide content.
struct GuideChapter: Codable, Equatable, Hashable, Sendable, Identifiable {
    /// Identity.
    var id = UUID()
    /// Chapter title as the user names it.
    var title: String
    /// Absolute https URL of the chapter page on GameFAQs.
    var url: String
}
