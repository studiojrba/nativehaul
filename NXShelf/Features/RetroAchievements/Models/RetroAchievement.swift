import Foundation

/// One achievement from `API_GetGameInfoAndUserProgress.php` (ADR 0047).
struct RetroAchievement: Decodable, Equatable, Sendable, Identifiable {
    private static let badgeBase = "https://media.retroachievements.org/Badge/"

    /// Achievement ID.
    let id: Int
    /// Title.
    let title: String
    /// Description.
    let description: String
    /// Points.
    let points: Int
    /// Badge image name.
    let badgeName: String
    /// Display order within the game.
    let displayOrder: Int
    /// When the user earned it (softcore or hardcore), if they have.
    let dateEarned: String?
    /// When the user earned it in hardcore, if they have.
    let dateEarnedHardcore: String?

    private enum CodingKeys: String, CodingKey {
        case id = "ID", title = "Title", description = "Description", points = "Points", badgeName = "BadgeName"
        case displayOrder = "DisplayOrder", dateEarned = "DateEarned", dateEarnedHardcore = "DateEarnedHardcore"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        points = try container.decodeIfPresent(Int.self, forKey: .points) ?? 0
        badgeName = try container.decodeIfPresent(String.self, forKey: .badgeName) ?? ""
        displayOrder = try container.decodeIfPresent(Int.self, forKey: .displayOrder) ?? 0
        dateEarned = try container.decodeIfPresent(String.self, forKey: .dateEarned)
        dateEarnedHardcore = try container.decodeIfPresent(String.self, forKey: .dateEarnedHardcore)
    }

    /// Whether the user has earned it.
    var isEarned: Bool {
        dateEarned != nil || dateEarnedHardcore != nil
    }

    /// The badge image (the grey locked variant while unearned).
    var badgeURL: URL? {
        URL(string: Self.badgeBase + badgeName + (isEarned ? "" : "_lock") + ".png")
    }
}
