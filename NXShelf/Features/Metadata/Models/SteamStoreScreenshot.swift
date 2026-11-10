import Foundation

/// A Steam store screenshot.
struct SteamStoreScreenshot: Decodable, Sendable {
    /// Full-size image URL.
    let pathFull: String?
}
