import Foundation

/// Builds the details info list and the grid caption. All formatting lives here, not in views.
///
/// "Time Played" lists each real source separately (e.g. "12h Steam · 3h Mac") — never a merged total (ADR 0006).
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
            GameInfoRow(label: "Platform", value: game.platform.displayName),
            GameInfoRow(label: "Tags", value: game.tags.isEmpty ? unknown : game.tags.joined(separator: ", ")),
        ]
    }

    /// Caption under a grid poster: platform plus per-source playtime when any.
    static func gridCaption(for game: Game) -> String {
        [game.platform.displayName, timePlayed(game)].compactMap(\.self).joined(separator: separator)
    }

    /// Where the game comes from: Steam locations, the tracked app, or the library.
    static func source(_ game: Game) -> String {
        var sources = game.steamInstalls.map(\.displayName)
        if game.steamAppID != nil, sources.isEmpty {
            sources.append("Steam")
        }
        if game.appBundlePath != nil {
            sources.append("Local app")
        }
        return sources.isEmpty ? "Library entry" : sources.joined(separator: ", ")
    }

    /// Per-source real playtime ("12h Steam · 3h Mac"), or `nil` when nothing is recorded.
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
}
