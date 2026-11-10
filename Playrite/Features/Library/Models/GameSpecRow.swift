import Foundation

/// One row of the detail page's specs table (ADR 0039): a small label and its value.
struct GameSpecRow: Equatable, Hashable, Sendable, Identifiable {
    /// Label ("Release date").
    let label: String
    /// Value.
    let value: String

    /// Identity.
    var id: String {
        label
    }

    /// Rows for `game`, only where the data exists: no empty rows, no placeholders.
    @MainActor
    static func rows(for game: Game) -> [GameSpecRow] {
        var rows: [GameSpecRow] = []
        if let date = game.releaseDate {
            rows.append(GameSpecRow(label: "Release date", value: date.formatted(date: .long, time: .omitted)))
        }
        if !game.genres.isEmpty {
            rows.append(GameSpecRow(label: "Genres", value: game.genres.joined(separator: ", ")))
        }
        if let developer = game.developer?.trimmingCharacters(in: .whitespaces), !developer.isEmpty {
            rows.append(GameSpecRow(label: "Developer", value: developer))
        }
        if !game.tags.isEmpty {
            rows.append(GameSpecRow(label: "Features", value: game.tags.joined(separator: ", ")))
        }
        rows.append(GameSpecRow(label: "Platform", value: GameInfoBuilder.platformName(game)))
        rows.append(GameSpecRow(label: "Source", value: GameInfoBuilder.source(game)))
        if let bytes = game.installSizeBytes {
            rows.append(GameSpecRow(
                label: "Install size",
                value: ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
            ))
        }
        return rows
    }
}
