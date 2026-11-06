import Foundation

/// Link-out URLs on howlongtobeat.com. Playrite never fetches these pages; it only opens them in the browser.
enum HLTBLink {
    private static let gameBase = "https://howlongtobeat.com/game/"

    /// The game's own page when its HLTB identifier is known.
    static func gameURL(id: Int) -> URL? {
        URL(string: gameBase + String(id))
    }
}
