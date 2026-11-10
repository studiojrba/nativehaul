import Foundation

/// Steam pages the setup screen links to.
enum SteamLinks {
    /// Where Steam issues Web API keys.
    static let apiKeyPage = URL(string: "https://steamcommunity.com/dev/apikey")
    /// The signed-in user's privacy settings.
    static let privacySettings = URL(string: "https://steamcommunity.com/my/edit/settings")
}
