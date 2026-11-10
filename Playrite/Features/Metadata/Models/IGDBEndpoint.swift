import Foundation

/// IGDB and Twitch endpoints and the query Retriever sends (ADR 0038).
enum IGDBEndpoint {
    /// Twitch's token endpoint (client-credentials grant).
    static let token = URL(string: "https://id.twitch.tv/oauth2/token")
    /// IGDB's games endpoint.
    static let games = URL(string: "https://api.igdb.com/v4/games")
    /// IGDB's platform ID for Nintendo Switch.
    private static let nintendoSwitch = 130
    /// IGDB's platform ID for Nintendo Switch 2.
    private static let nintendoSwitch2 = 508
    /// IGDB platform IDs searched: Nintendo Switch and Nintendo Switch 2.
    static let switchPlatforms = [nintendoSwitch, nintendoSwitch2]
    private static let resultLimit = 20

    /// The form body for a token request. Credentials go in the body, never the URL.
    static func tokenBody(_ credentials: IGDBCredentials) -> Data {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: credentials.clientID),
            URLQueryItem(name: "client_secret", value: credentials.clientSecret),
            URLQueryItem(name: "grant_type", value: "client_credentials"),
        ]
        return Data((components.percentEncodedQuery ?? "").utf8)
    }

    /// The Apicalypse query for Switch games named like `title`.
    static func searchBody(title: String) -> Data {
        let escaped = title.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let platforms = switchPlatforms.map(String.init).joined(separator: ",")
        return Data(("search \"\(escaped)\"; fields name,summary,screenshots.image_id,videos.video_id; "
                + "where platforms = (\(platforms)); limit \(resultLimit);").utf8)
    }

    /// A 1080p screenshot URL.
    static func screenshot(imageID: String) -> URL? {
        URL(string: "https://images.igdb.com/igdb/image/upload/t_1080p/\(imageID).jpg")
    }

    /// YouTube's watch URL for a video, the form stored as the trailer.
    static func youTubeWatch(videoID: String) -> URL? {
        URL(string: "https://www.youtube.com/watch?v=\(videoID)")
    }

    /// YouTube's poster stills for a video, best first.
    static func youTubePosters(videoID: String) -> [URL] {
        ["maxresdefault", "hqdefault"].compactMap { URL(string: "https://i.ytimg.com/vi/\(videoID)/\($0).jpg") }
    }
}
