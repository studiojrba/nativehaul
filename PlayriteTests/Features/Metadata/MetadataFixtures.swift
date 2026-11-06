import Foundation
@testable import Playrite

/// Recorded-shape fixtures for metadata tests. No test touches the network.
enum MetadataFixtures {
    static let jpegBytes = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10])
    static let pngBytes = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A])
    static let htmlBytes = Data("<html>Not found</html>".utf8)

    static let portalDetails = """
    {"620": {"success": true, "data": {
      "type": "game", "name": "Portal 2", "steam_appid": 620,
      "short_description": "The &quot;Perpetual Testing Initiative&quot; continues.",
      "about_the_game": "<p>Long <b>HTML</b></p>",
      "developers": ["Valve"],
      "genres": [{"id": "1", "description": "Action"}, {"id": "25", "description": "Adventure"}],
      "categories": [{"id": 2, "description": "Single-player"}, {"id": 9, "description": "Co-op"}],
      "release_date": {"coming_soon": false, "date": "18 Apr, 2011"},
      "header_image": "https://cdn.example/steam/apps/620/header.jpg",
      "background_raw": "https://cdn.example/steam/apps/620/page_bg_raw.jpg",
      "screenshots": [
        {"id": 0, "path_thumbnail": "https://cdn.example/s0t.jpg", "path_full": "https://cdn.example/s0.jpg"},
        {"id": 1, "path_thumbnail": "https://cdn.example/s1t.jpg", "path_full": "https://cdn.example/s1.jpg"}
      ],
      "movies": [{"id": 5, "name": "Trailer", "thumbnail": "https://cdn.example/m0.jpg"}]
    }}}
    """

    static let failedDetails = #"{"999": {"success": false}}"#

    static let searchHades = """
    {"total": 3, "items": [
      {"type": "app", "name": "Hades II", "id": 1145350},
      {"type": "app", "name": "Hades", "id": 1145360},
      {"type": "app", "name": "Hadestown", "id": 42}
    ]}
    """

    static let searchAmbiguous = """
    {"total": 2, "items": [
      {"type": "app", "name": "Tideborn", "id": 1},
      {"type": "app", "name": "TIDEBORN™", "id": 2}
    ]}
    """

    static let sgdbGame = #"{"success": true, "data": {"id": 777, "name": "Portal 2"}}"#
    static let sgdbGrids = """
    {"success": true, "data": [
      {"id": 1, "url": "https://sgdb.example/nsfw.png", "style": "alternate", "nsfw": true, "humor": false},
      {"id": 2, "url": "https://sgdb.example/joke.png", "style": "alternate", "nsfw": false, "humor": true},
      {"id": 3, "url": "https://sgdb.example/blur.png", "style": "blurred", "nsfw": false, "humor": false},
      {"id": 4, "url": "https://sgdb.example/good.png", "style": "alternate", "nsfw": false, "humor": false}
    ]}
    """
    static let sgdbHeroes = """
    {"success": true, "data": [{"id": 9, "url": "https://sgdb.example/hero.png", "style": "alternate"}]}
    """

    static func switchHit(id: String, title: String, platforms: [String]? = ["Nintendo Switch"]) -> NintendoStoreHit {
        NintendoStoreHit(
            listingID: id,
            title: title,
            description: "<p>Sail the <b>tides</b>.</p>",
            developer: "Harbor Lights",
            genres: ["Adventure"],
            releaseDate: "2021-06-10T07:00:00.000Z",
            keyArtURL: "https://assets.example/\(id)/key-art.jpg",
            platforms: platforms
        )
    }
}
