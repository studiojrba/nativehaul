import Foundation

/// Builds Steam Web API URLs. The key must travel as a query parameter per Steam's API; URLs are never logged.
enum SteamEndpoint {
    private static let host = "api.steampowered.com"
    private static let language = "english"

    /// `IPlayerService/GetOwnedGames/v1`.
    static func ownedGames(_ credentials: SteamCredentials) -> URL? {
        url(path: "/IPlayerService/GetOwnedGames/v1/", credentials: credentials, extra: [
            URLQueryItem(name: "include_appinfo", value: "1"),
            URLQueryItem(name: "include_played_free_games", value: "1"),
        ])
    }

    /// `IPlayerService/GetRecentlyPlayedGames/v1`.
    static func recentlyPlayedGames(_ credentials: SteamCredentials) -> URL? {
        url(path: "/IPlayerService/GetRecentlyPlayedGames/v1/", credentials: credentials, extra: [])
    }

    /// `ISteamUser/GetPlayerSummaries/v2` (takes `steamids`, so it is built without the `steamid` parameter).
    static func playerSummaries(_ credentials: SteamCredentials) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/ISteamUser/GetPlayerSummaries/v2/"
        components.queryItems = [
            URLQueryItem(name: "key", value: credentials.apiKey),
            URLQueryItem(name: "steamids", value: credentials.steamID.rawValue),
            URLQueryItem(name: "format", value: "json"),
        ]
        return components.url
    }

    /// `ISteamUserStats/GetPlayerAchievements/v1`.
    static func playerAchievements(appID: Int, credentials: SteamCredentials) -> URL? {
        url(path: "/ISteamUserStats/GetPlayerAchievements/v1/", credentials: credentials, extra: [
            URLQueryItem(name: "appid", value: String(appID)),
            URLQueryItem(name: "l", value: language),
        ])
    }

    private static func url(path: String, credentials: SteamCredentials, extra: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "key", value: credentials.apiKey),
            URLQueryItem(name: "steamid", value: credentials.steamID.rawValue),
            URLQueryItem(name: "format", value: "json"),
        ] + extra
        return components.url
    }
}
