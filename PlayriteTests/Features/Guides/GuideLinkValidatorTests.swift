import Foundation
@testable import Playrite
import Testing

struct GuideLinkValidatorTests {
    private let guide = "https://gamefaqs.gamespot.com/switch/123-tideborn/faqs/45678"

    @Test func acceptsGameFAQs() throws {
        #expect(try GuideLinkValidator.validateGuideURL(guide).host() == "gamefaqs.gamespot.com")
        #expect(throws: Never.self) { try GuideLinkValidator.validateGuideURL("https://www.gamefaqs.com/x/faqs/1") }
    }

    @Test(arguments: [
        "http://gamefaqs.gamespot.com/switch/1/faqs/2",
        "https://gamefaqs.gamespot.com.evil.example/faqs/1",
        "https://example.com/faqs/1",
        "not a url",
        "",
    ])
    func rejectsOtherLinks(input: String) {
        #expect(throws: GuideLinkError.self) { try GuideLinkValidator.validateGuideURL(input) }
    }

    @Test func chapterMustBeInSameGuide() throws {
        #expect(throws: Never.self) {
            try GuideLinkValidator.validateChapterURL(guide + "/chapter-3-the-tide", guideURL: guide)
        }
        #expect(throws: GuideLinkError.chapterOutsideGuide) {
            try GuideLinkValidator.validateChapterURL(
                "https://gamefaqs.gamespot.com/switch/123-tideborn/faqs/99999/x",
                guideURL: guide
            )
        }
    }

    @Test func guidePathStopsAtGuideID() throws {
        let url = try #require(URL(string: guide + "/walkthrough?page=2"))
        #expect(GuideLinkValidator.guidePath(of: url) == "/switch/123-tideborn/faqs/45678")
    }

    @Test func attributionRequired() {
        #expect(throws: GuideLinkError.missingAttribution) { try GuideLinkValidator.validateAttribution(
            title: "Walkthrough",
            author: " "
        ) }
        let text = GuideAttribution.text(title: "Walkthrough", author: "Jane Doe")
        #expect(text.contains("Jane Doe"))
        #expect(text.contains("GameFAQs"))
        #expect(text.contains("gamefaqs.gamespot.com"))
    }
}
