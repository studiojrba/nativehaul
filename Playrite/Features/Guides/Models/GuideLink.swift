import Foundation
import SwiftData

/// A link to an external GameFAQs guide for a game, with attribution and chapter links.
///
/// Playrite links out only: it never downloads, scrapes, caches or embeds guide content.
@Model
final class GuideLink {
    /// Identity.
    @Attribute(.unique) var id: UUID
    /// Guide title as published.
    var title: String
    /// Guide author (credited wherever the link is shown).
    var author: String
    /// Absolute https URL of the guide on GameFAQs.
    var url: String
    /// Chapter links in reading order.
    var chapters: [GuideChapter] = []
    /// The chapter the player is currently on.
    var currentChapterID: UUID?
    /// When the link was added.
    var addedAt: Date
    /// Owning game.
    var game: Game?

    /// Creates a guide link.
    init(id: UUID = UUID(), title: String, author: String, url: String, addedAt: Date = .now) {
        self.id = id
        self.title = title
        self.author = author
        self.url = url
        self.addedAt = addedAt
    }

    /// The current chapter, if set.
    var currentChapter: GuideChapter? {
        chapters.first { $0.id == currentChapterID }
    }

    /// Full attribution line shown with every link.
    var attribution: String {
        GuideAttribution.text(title: title, author: author)
    }
}
