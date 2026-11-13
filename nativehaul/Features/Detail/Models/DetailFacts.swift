import Foundation

/// Detail's words and figures (spec §3.3), all from the game's real data: the eyebrow, the visual caption, the Play
/// label, the specs table, the editorial note and the case's print. Anything unknown is left out, never invented.
@MainActor
enum DetailFacts {
    /// Minutes in one "long evening" (spec §3.3 editorial note).
    static let minutesPerEvening = 120.0
    private static let secondsPerMinute = 60.0
    private static let dot = " · "

    /// "{genre} · {year}" (either part alone when only one is known), or `nil`.
    static func eyebrow(for game: Game) -> String? {
        joined([game.genres.first, year(of: game)], separator: dot)
    }

    /// "{studio} — {year}" under the case, or `nil`.
    static func caption(for game: Game) -> String? {
        joined([studio(of: game), year(of: game)], separator: " — ")
    }

    /// The case back's footer: "{studio} · {year}", or `nil`.
    static func caseFooter(for game: Game) -> String? {
        joined([studio(of: game), year(of: game)], separator: dot)
    }

    /// "Play" once there is playtime, "Start" before (spec §3.3).
    static func playLabel(for game: Game) -> String {
        game.biggestRealPlaytimeSeconds > 0 ? "Play" : "Start"
    }

    /// The release year, when known.
    static func year(of game: Game, calendar: Calendar = .current) -> String? {
        game.releaseDate.map { String(calendar.component(.year, from: $0)) }
    }

    /// The developer, when known.
    static func studio(of game: Game) -> String? {
        game.developer.flatMap { $0.trimmingCharacters(in: .whitespaces).isEmpty ? nil : $0 }
    }

    /// The playtime figure from the single biggest real source ("11h 40m"), labelled when it isn't Mac-tracked
    /// ("3h · self-reported"). Sources are never added together. `nil` before any play.
    static func playtime(for game: Game) -> String? {
        let entries = game.playtimeBreakdown().entries.filter { !$0.source.isEstimate }
        guard let top = entries.max(by: { $0.seconds < $1.seconds }) else { return nil }
        let figure = DurationFormatting.playtime(seconds: top.seconds)
        return top.source == .macTracked ? figure : figure + dot + "self-reported"
    }

    /// The platform, in plain words: "Nintendo Switch port", the emulated system's name, or "Mac".
    static func platform(of game: Game) -> String? {
        switch game.platform {
        case .switchPort: "Nintendo Switch port"
        case .emulated: game.emulatedSystem?.displayName ?? "Emulated"
        case .macNative: "Mac"
        case .other: nil
        }
    }

    /// How the game is played: natively for ports and Mac games, "Emulated · {system}" for ROMs. Emulator apps are
    /// never named here.
    static func playsWith(_ game: Game) -> String? {
        switch game.platform {
        case .switchPort, .macNative: game.appBundlePath == nil ? nil : "Native Mac app"
        case .emulated: joined(["Emulated", game.emulatedSystem?.displayName], separator: dot)
        case .other: nil
        }
    }

    /// The port's version, when known: "Base game" for version 0, else "v{n}".
    static func version(of game: Game) -> String? {
        guard let version = game.switchVersion else { return nil }
        return version == 0 ? "Base game" : "v\(version)"
    }

    /// The specs table rows in the design's order, each only when its value is real. `hltbSeconds` adds a labelled
    /// HLTB estimate row; `build` adds Build status.
    static func specs(for game: Game, build: DetailBuildState?, hltbSeconds: Int?, now: Date) -> [DetailSpecRow] {
        var rows: [DetailSpecRow] = []
        let add: (String, String?, DetailSpecRow.Style) -> Void = { label, value, style in
            if let value, !value.isEmpty {
                rows.append(DetailSpecRow(label: label, value: value, style: style))
            }
        }
        add("Playtime", playtime(for: game), .plain)
        add("HLTB estimate", hltbSeconds.map { DurationFormatting.playtime(seconds: $0) + " main story" }, .plain)
        add("Last played", game.lastPlayedDate.map { LastPlayedPhrase.phrase(for: $0, now: now) }, .plain)
        add("Platform", platform(of: game), .plain)
        add("Plays with", playsWith(game), .plain)
        add("Build status", build?.label, .status(isReady: build?.isReady ?? false))
        add(
            "File size",
            game.installSizeBytes.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) },
            .plain
        )
        add("Version", version(of: game), .plain)
        add("Game ID", game.switchTitleID?.uppercased(), .monospaced)
        return rows
    }

    /// Long evenings in `seconds` of play: `max(1, round(minutes / 120))`.
    static func evenings(seconds: Int) -> Int {
        max(1, Int((Double(seconds) / secondsPerMinute / minutesPerEvening).rounded()))
    }

    /// The editorial note (spec §3.3), only once there is playtime: "You've spent {playtime} here. That's {n} long
    /// evenings — not bad at all."
    static func editorialNote(for game: Game) -> String? {
        let seconds = game.biggestRealPlaytimeSeconds
        guard seconds > 0 else { return nil }
        let count = evenings(seconds: seconds)
        let evenings = count == 1 ? "one long evening" : "\(count) long evenings"
        let playtime = DurationFormatting.playtime(seconds: seconds)
        return "You’ve spent \(playtime) here. That’s \(evenings) — not bad at all."
    }

    /// Screenshots for the case back and "Screenshots": the game's cached media, in order.
    static func screenshots(for game: Game) -> [String] {
        game.carouselImagePaths
    }

    /// The identifier the barcode is drawn from: the title ID, else the library ID.
    static func barcodeSource(for game: Game) -> String {
        game.switchTitleID ?? game.id.uuidString
    }

    /// Switch ports get the red case; everything else the charcoal one.
    static func caseColors(for game: Game) -> CaseColors {
        game.platform == .switchPort ? .red : .charcoal
    }

    private static func joined(_ parts: [String?], separator: String) -> String? {
        let present = parts.compactMap(\.self).filter { !$0.isEmpty }
        return present.isEmpty ? nil : present.joined(separator: separator)
    }
}
