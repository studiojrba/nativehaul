import Foundation
import SwiftData

/// A game in the player's library.
@Model
final class Game {
    /// Stable identifier used for import/export and cross-references.
    @Attribute(.unique) var id: UUID
    /// Display title.
    var title: String
    /// Raw storage for ``platform``.
    var platformRaw: String
    /// Raw storage for ``status``.
    var statusRaw: String
    /// Short free-form description or notes.
    var summary: String
    /// Original release date, if known.
    var releaseDate: Date?
    /// When the game was added to Playrite.
    var addedAt: Date
    /// When the game was marked completed.
    var completedAt: Date?
    /// Most recent play time from any real source.
    var lastPlayedAt: Date?
    /// Absolute path to a local cover image.
    var coverImagePath: String?
    /// Steam application ID, when the game is a Steam title.
    var steamAppID: Int?
    /// Absolute path to a tracked `.app` bundle on disk.
    var appBundlePath: String?
    /// Lifetime playtime reported by Steam (seconds). Source: ``PlaytimeSource/steamSynced``.
    var steamSyncedSeconds: Int?
    /// Playtime the player entered by hand (seconds). Source: ``PlaytimeSource/selfReported``.
    var selfReportedSeconds: Int?
    /// Steam achievements unlocked, from the last achievements load.
    var steamAchievementsUnlocked: Int?
    /// Steam achievements available, from the last achievements load.
    var steamAchievementsTotal: Int?
    /// Where this game is installed in Steam (Mac Steam and/or CrossOver bottles). Recomputed on every scan.
    var steamInstalls: [SteamInstallLocation] = []
    /// Size on disk in bytes, when known (from Steam's manifest or the `.app` bundle).
    var installSizeBytes: Int64?
    /// Developer studio, when known.
    var developer: String?
    /// Genres (display order).
    var genres: [String] = []
    /// Free-form tags (display order).
    var tags: [String] = []
    /// Absolute path to a local wide hero/background image for the details screen.
    var heroImagePath: String?
    /// HowLongToBeat game identifier, when known (used for a direct link-out; never fetched).
    var hltbID: Int?
    /// Recorded play sessions.
    @Relationship(deleteRule: .cascade, inverse: \PlaySession.game) var sessions: [PlaySession] = []
    /// External guide links (link-out only).
    @Relationship(deleteRule: .cascade, inverse: \GuideLink.game) var guides: [GuideLink] = []

    /// Creates a game.
    init(
        id: UUID = UUID(),
        title: String,
        platform: GamePlatform = .other,
        status: GameStatus = .backlog,
        summary: String = "",
        releaseDate: Date? = nil,
        addedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        platformRaw = platform.rawValue
        statusRaw = status.rawValue
        self.summary = summary
        self.releaseDate = releaseDate
        self.addedAt = addedAt
    }

    /// Typed platform.
    var platform: GamePlatform {
        get { GamePlatform(rawValue: platformRaw) ?? .other }
        set { platformRaw = newValue.rawValue }
    }

    /// Typed status.
    var status: GameStatus {
        get { GameStatus(rawValue: statusRaw) ?? .backlog }
        set { statusRaw = newValue.rawValue }
    }
}
