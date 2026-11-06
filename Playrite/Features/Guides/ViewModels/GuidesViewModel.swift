import Foundation
import Observation

/// Guide links for one game. Link-out only: nothing is fetched or embedded.
@MainActor
@Observable
final class GuidesViewModel {
    /// The game.
    let game: Game
    /// Last validation or save error.
    private(set) var errorMessage: String?

    private let repository: any LibraryRepository
    private let opener: any URLOpening

    /// Creates the view model.
    init(game: Game, repository: any LibraryRepository, opener: any URLOpening) {
        self.game = game
        self.repository = repository
        self.opener = opener
    }

    /// Guides in the order added.
    var guides: [GuideLink] {
        game.guides.sorted { $0.addedAt < $1.addedAt }
    }

    /// Adds a guide after validating the URL host and attribution. Returns `true` on success.
    @discardableResult
    func addGuide(title: String, author: String, url: String) -> Bool {
        perform {
            try GuideLinkValidator.validateAttribution(title: title, author: author)
            let validURL = try GuideLinkValidator.validateGuideURL(url)
            let guide = GuideLink(
                title: title.trimmingCharacters(in: .whitespaces),
                author: author.trimmingCharacters(in: .whitespaces),
                url: validURL.absoluteString
            )
            repository.insert(guide)
            guide.game = game
        }
    }

    /// Adds a chapter link within the same guide. Returns `true` on success.
    @discardableResult
    func addChapter(to guide: GuideLink, title: String, url: String) -> Bool {
        perform {
            let trimmed = title.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { throw GuideLinkError.missingAttribution }
            let validURL = try GuideLinkValidator.validateChapterURL(url, guideURL: guide.url)
            guide.chapters.append(GuideChapter(title: trimmed, url: validURL.absoluteString))
        }
    }

    /// Marks the chapter the player is on.
    func setCurrentChapter(_ chapter: GuideChapter?, in guide: GuideLink) {
        perform { guide.currentChapterID = chapter?.id }
    }

    /// Removes a guide link.
    func remove(_ guide: GuideLink) {
        perform { repository.delete(guide) }
    }

    /// Opens the guide (or its current chapter) in the browser.
    func continueReading(_ guide: GuideLink) {
        open(guide.currentChapter?.url ?? guide.url)
    }

    /// Opens a specific chapter in the browser.
    func open(_ chapter: GuideChapter) {
        open(chapter.url)
    }

    private func open(_ string: String) {
        if let url = try? GuideLinkValidator.validateGuideURL(string) {
            opener.open(url)
        }
    }

    @discardableResult
    private func perform(_ change: () throws -> Void) -> Bool {
        do {
            try change()
            try repository.save()
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
