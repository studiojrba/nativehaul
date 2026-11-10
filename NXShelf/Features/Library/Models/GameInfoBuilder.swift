import Foundation

/// Builds the details info list and the grid caption. All formatting lives here, not in views.
///
/// "Time Played" lists each real source separately (e.g. "12h Mac · 3h self-reported") — never a merged total (ADR
/// 0006).
@MainActor
enum GameInfoBuilder {
    /// Placeholder for unknown values.
    static let unknown = "—"
    private static let separator = " · "

    /// Status, Install Size, Time Played, Developer, Source, Release Date, Date Added, Platform, Tags.
    static func rows(for game: Game) -> [GameInfoRow] {
        [
            GameInfoRow(label: "Status", value: game.status.displayName),
            GameInfoRow(label: "Install Size", value: installSize(game)),
            GameInfoRow(label: "Time Played", value: timePlayed(game) ?? "Not played"),
            GameInfoRow(label: "Developer", value: game.developer ?? unknown),
            GameInfoRow(label: "Source", value: source(game)),
            GameInfoRow(label: "Release Date", value: date(game.releaseDate)),
            GameInfoRow(label: "Date Added", value: date(game.addedAt)),
            GameInfoRow(label: "Platform", value: platformName(game)),
            GameInfoRow(label: "Tags", value: game.tags.isEmpty ? unknown : game.tags.joined(separator: ", ")),
        ]
    }

    /// Caption under a grid poster: platform plus per-source playtime when any.
    static func gridCaption(for game: Game) -> String {
        [platformName(game), timePlayed(game)].compactMap(\.self).joined(separator: separator)
    }

    /// The poster's one secondary line (ADR 0025): the largest real playtime figure with its source label ("66h 42m ·
    /// MacTracked"), or the status when nothing has been played. Sources are never added together.
    static func cardLine(for game: Game) -> String {
        let entries = game.playtimeBreakdown().entries.filter { !$0.source.isEstimate }
        guard let top = entries.max(by: { $0.seconds < $1.seconds }) else { return game.status.displayName }
        return "\(DurationFormatting.compact(seconds: top.seconds)) · \(top.source.label)"
    }

    /// Where the game comes from: the app on disk, the ROM, or only the library.
    static func source(_ game: Game) -> String {
        if game.appBundlePath != nil {
            return "Local app"
        }
        return game.romPath != nil ? "ROM file" : "Library entry"
    }

    /// Per-source real playtime ("12h Mac · 3h self-reported"), or `nil` when nothing is recorded.
    static func timePlayed(_ game: Game) -> String? {
        let entries = game.playtimeBreakdown().entries
        guard !entries.isEmpty else { return nil }
        return entries
            .map { "\(DurationFormatting.compact(seconds: $0.seconds)) \($0.source.label)" }
            .joined(separator: separator)
    }

    private static func installSize(_ game: Game) -> String {
        game.installSizeBytes.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) } ?? unknown
    }

    private static func date(_ date: Date?) -> String {
        date?.formatted(date: .abbreviated, time: .omitted) ?? unknown
    }

    /// "Emulated · Game Boy Advance" for emulated games, otherwise the platform name.
    static func platformName(_ game: Game) -> String {
        guard game.platform == .emulated, let system = game.emulatedSystem else { return game.platform.displayName }
        return "\(game.platform.displayName) · \(system.displayName)"
    }
}
