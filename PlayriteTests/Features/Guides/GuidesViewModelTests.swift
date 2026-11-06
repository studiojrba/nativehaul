import Foundation
@testable import Playrite
import Testing

@MainActor
struct GuidesViewModelTests {
    private let guideURL = "https://gamefaqs.gamespot.com/switch/123-tideborn/faqs/45678"

    private func make() throws -> (GuidesViewModel, RecordingURLOpener, MockLibraryRepository, Game) {
        let repository = try MockLibraryRepository()
        let game = Game(title: "Tideborn")
        repository.insert(game)
        try repository.save()
        let opener = RecordingURLOpener()
        return (GuidesViewModel(game: game, repository: repository, opener: opener), opener, repository, game)
    }

    @Test func addGuideValidatesAndStoresLinkOnly() throws {
        let (viewModel, _, _, _) = try make()
        #expect(!viewModel.addGuide(title: "Walkthrough", author: "", url: guideURL))
        #expect(viewModel.errorMessage == GuideLinkError.missingAttribution.errorDescription)
        #expect(!viewModel.addGuide(title: "Walkthrough", author: "Jane", url: "https://example.com/faqs/1"))
        #expect(viewModel.addGuide(title: " Walkthrough ", author: "Jane", url: guideURL))
        #expect(viewModel.guides.map(\.title) == ["Walkthrough"])
        #expect(viewModel.guides.first?.attribution.contains("Jane") == true)
    }

    @Test func chapterAwareContinueReading() throws {
        let (viewModel, opener, _, _) = try make()
        viewModel.addGuide(title: "Walkthrough", author: "Jane", url: guideURL)
        let guide = try #require(viewModel.guides.first)
        viewModel.continueReading(guide)
        #expect(opener.opened.last?.absoluteString == guideURL)

        #expect(viewModel.addChapter(to: guide, title: "Chapter 3", url: guideURL + "/chapter-3"))
        #expect(!viewModel.addChapter(
            to: guide,
            title: "Elsewhere",
            url: "https://gamefaqs.gamespot.com/switch/9/faqs/1"
        ))
        let chapter = try #require(guide.chapters.first)
        viewModel.setCurrentChapter(chapter, in: guide)
        viewModel.continueReading(guide)
        #expect(opener.opened.last?.absoluteString == guideURL + "/chapter-3")
        #expect(opener.opened.count == 2)
    }

    @Test func guidesSurviveArchiveRoundTrip() throws {
        let (viewModel, _, repository, _) = try make()
        viewModel.addGuide(title: "Walkthrough", author: "Jane", url: guideURL)
        let guide = try #require(viewModel.guides.first)
        viewModel.addChapter(to: guide, title: "Ch 1", url: guideURL + "/ch-1")
        let data = try LibraryTransferService(repository: repository).exportData()

        let destination = try MockLibraryRepository()
        _ = try LibraryTransferService(repository: destination).importData(data)
        let imported = try #require(try destination.fetchGames().first?.guides.first)
        #expect(imported.author == "Jane")
        #expect(imported.chapters.map(\.title) == ["Ch 1"])
    }

    @Test func archivesWithoutGuidesStillImport() throws {
        let json = """
        {"formatVersion":1,"exportedAt":"2026-01-01T00:00:00Z","series":[],"collections":[],"games":[{
          "id":"6F9619FF-8B86-D011-B42D-00C04FC964FF","title":"Old","platform":"steam","status":"backlog",
          "summary":"","addedAt":"2026-01-01T00:00:00Z","sessions":[]}]}
        """
        let repository = try MockLibraryRepository()
        let summary = try LibraryTransferService(repository: repository).importData(Data(json.utf8))
        #expect(summary.gamesAdded == 1)
    }
}
