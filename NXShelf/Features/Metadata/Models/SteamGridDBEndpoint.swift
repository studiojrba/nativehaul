import Foundation

/// SteamGridDB API v2 URLs. The key travels only in the `Authorization` header.
enum SteamGridDBEndpoint {
    private static let base = "https://www.steamgriddb.com/api/v2"
    private static let portraitDimensions = "600x900,342x482,660x930"
    private static let safeFilters = [
        URLQueryItem(name: "types", value: "static"),
        URLQueryItem(name: "nsfw", value: "false"),
        URLQueryItem(name: "humor", value: "false"),
        URLQueryItem(name: "epilepsy", value: "false"),
    ]

    /// Title autocomplete search.
    static func search(term: String) -> URL? {
        guard let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.subtracting(["/"]))
        else { return nil }
        return URL(string: "\(base)/search/autocomplete/\(encoded)")
    }

    /// Portrait grids for a game, highest score first.
    static func portraitGrids(gameID: Int) -> URL? {
        url("\(base)/grids/game/\(gameID)", query: [URLQueryItem(name: "dimensions", value: portraitDimensions)])
    }

    /// Heroes for a game, highest score first.
    static func heroes(gameID: Int) -> URL? {
        url("\(base)/heroes/game/\(gameID)", query: [])
    }

    private static func url(_ string: String, query: [URLQueryItem]) -> URL? {
        var components = URLComponents(string: string)
        components?.queryItems = query + safeFilters
        return components?.url
    }
}
