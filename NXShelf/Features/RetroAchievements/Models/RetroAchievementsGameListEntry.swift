import Foundation

/// One game from `API_GetGameList.php` with its supported ROM hashes.
struct RetroAchievementsGameListEntry: Decodable, Equatable, Sendable {
    /// Game ID.
    let id: Int
    /// Title.
    let title: String
    /// Supported ROM hashes (lowercase MD5).
    let hashes: [String]

    private enum CodingKeys: String, CodingKey {
        case id = "ID", title = "Title", hashes = "Hashes"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        hashes = try container.decodeIfPresent([String].self, forKey: .hashes) ?? []
    }

    /// Creates an entry.
    init(id: Int, title: String, hashes: [String]) {
        self.id = id
        self.title = title
        self.hashes = hashes
    }
}
