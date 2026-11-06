import Foundation

/// Validates guide and chapter URLs. Pure — makes no network requests.
enum GuideLinkValidator {
    private static let allowedHosts: Set<String> = ["gamefaqs.gamespot.com", "www.gamefaqs.com", "gamefaqs.com"]
    private static let guideSegment = "faqs"

    /// Validates a guide URL and returns it normalised.
    static func validateGuideURL(_ string: String) throws -> URL {
        let url = try httpsURL(string)
        guard let host = url.host()?.lowercased(), allowedHosts.contains(host) else { throw GuideLinkError.notGameFAQs }
        return url
    }

    /// Validates a chapter URL: same host family and inside the guide's path.
    static func validateChapterURL(_ string: String, guideURL: String) throws -> URL {
        let chapter = try validateGuideURL(string)
        let guide = try validateGuideURL(guideURL)
        guard chapter.path().hasPrefix(guidePath(of: guide)) else { throw GuideLinkError.chapterOutsideGuide }
        return chapter
    }

    /// Validates attribution fields.
    static func validateAttribution(title: String, author: String) throws {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !author.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            throw GuideLinkError.missingAttribution
        }
    }

    /// The guide's base path: up to and including `/faqs/<id>`, else the full path.
    static func guidePath(of url: URL) -> String {
        let components = url.path().split(separator: "/")
        guard let index = components.firstIndex(of: Substring(guideSegment)), index + 1 < components.count else {
            return url.path()
        }
        return "/" + components[...(index + 1)].joined(separator: "/")
    }

    private static func httpsURL(_ string: String) throws -> URL {
        guard let url = URL(string: string.trimmingCharacters(in: .whitespacesAndNewlines)),
              url.scheme?.lowercased() == "https", url.host() != nil
        else { throw GuideLinkError.invalidURL }
        return url
    }
}
