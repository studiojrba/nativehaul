import Foundation

/// Builds the attribution line shown alongside every guide link.
enum GuideAttribution {
    /// Site credited for guides.
    static let siteName = "GameFAQs"
    /// Site host.
    static let siteHost = "gamefaqs.gamespot.com"

    /// e.g. "“Walkthrough” by Jane Doe on GameFAQs (gamefaqs.gamespot.com). © the author. Opens in your browser."
    static func text(title: String, author: String) -> String {
        let credit = author.trimmingCharacters(in: .whitespaces).isEmpty ? "an unnamed author" : author
        return "“\(title)” by \(credit) on \(siteName) (\(siteHost)). © the author. Opens in your browser."
    }
}
