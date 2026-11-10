import Foundation

/// Public Steam store URLs (no Web API key involved).
enum SteamStoreEndpoint {
    private static let storeHost = "store.steampowered.com"
    private static let assetBase = "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps"
    private static let legacyAssetBase = "https://cdn.cloudflare.steamstatic.com/steam/apps"
    private static let language = "english"
    private static let country = "us"

    /// `api/appdetails` for one app.
    static func appDetails(appID: Int) -> URL? {
        store(path: "/api/appdetails", query: [
            URLQueryItem(name: "appids", value: String(appID)),
            URLQueryItem(name: "l", value: language),
            URLQueryItem(name: "cc", value: country),
        ])
    }

    /// `api/storesearch` for a title.
    static func search(term: String) -> URL? {
        store(path: "/api/storesearch/", query: [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "l", value: language),
            URLQueryItem(name: "cc", value: country),
        ])
    }

    /// Official portrait library capsules (600×900), best first. Older apps may not have one.
    static func libraryCapsules(appID: Int) -> [URL] {
        ["library_600x900_2x.jpg", "library_600x900.jpg"].flatMap { assetURLs(appID: appID, file: $0) }
    }

    /// Official library hero (wide, no logo).
    static func libraryHero(appID: Int) -> [URL] {
        assetURLs(appID: appID, file: "library_hero.jpg")
    }

    private static func assetURLs(appID: Int, file: String) -> [URL] {
        [assetBase, legacyAssetBase].compactMap { URL(string: "\($0)/\(appID)/\(file)") }
    }

    private static func store(path: String, query: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = storeHost
        components.path = path
        components.queryItems = query
        return components.url
    }
}
