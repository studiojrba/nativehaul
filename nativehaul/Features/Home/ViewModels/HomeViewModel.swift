import Foundation
import Observation

/// Home's state (spec §3.1), from the real library: the hero slides (one per Jump Back In game, with generated copy),
/// Continue playing (Jump Back In ranks 2–4), the whole-shelf summary, and each hero game's palette from its artwork.
///
/// When Jump Back In is empty the hero falls back to one calm slide for the most recently played (else most recently
/// added) game, with neutral copy — never a fake "keep playing".
@MainActor
@Observable
final class HomeViewModel {
    /// The shared library.
    let library: LibraryViewModel
    /// The hero's carousel (kept here so it survives leaving Home).
    let carousel: HeroCarousel
    /// Palettes derived so far, by game.
    private(set) var palettes: [UUID: GamePalette] = [:]

    /// Continue playing shows Jump Back In ranks 2–4.
    static let continueCount = 3

    @ObservationIgnored private let paletteExtractor: any GamePaletteExtracting
    @ObservationIgnored private let now: @MainActor () -> Date

    /// Creates Home's state.
    init(
        library: LibraryViewModel,
        paletteExtractor: any GamePaletteExtracting,
        carousel: HeroCarousel = HeroCarousel(),
        now: @escaping @MainActor () -> Date = { Date() }
    ) {
        self.library = library
        self.paletteExtractor = paletteExtractor
        self.carousel = carousel
        self.now = now
    }

    /// `true` when there are no games at all.
    var isLibraryEmpty: Bool {
        library.games.isEmpty
    }

    /// Jump Back In (spec §1.10): Playing, or unfinished and played in the last 30 days, most recent first.
    var jumpBackIn: [Game] {
        JumpBackIn.games(from: library.games, now: now())
    }

    /// The hero's slides: Jump Back In (at most ``ShellLayout/Hero/maximumSlides``), or the calm fallback.
    var slides: [HeroSlide] {
        let reference = now()
        let members = jumpBackIn.prefix(ShellLayout.Hero.maximumSlides)
        if !members.isEmpty {
            return members.map { HeroSlide(game: $0, copy: HeroCopyWriter.copy(for: $0, now: reference)) }
        }
        guard let game = fallbackGame else { return [] }
        return [HeroSlide(game: game, copy: HeroCopyWriter.copy(for: game, now: reference, isFallback: true))]
    }

    /// The fallback hero game: the most recently played, else the most recently added.
    var fallbackGame: Game? {
        let played = library.games.compactMap { game in game.lastPlayedDate.map { (game, $0) } }
        if let latest = played.max(by: { $0.1 < $1.1 }) {
            return latest.0
        }
        return library.games.max { $0.addedAt < $1.addedAt }
    }

    /// Continue playing: Jump Back In ranks 2–4.
    var continuing: [Game] {
        Array(jumpBackIn.dropFirst().prefix(Self.continueCount))
    }

    /// The whole shelf in two numbers.
    var shelfSummary: ShelfSummary {
        ShelfSummary(games: library.games)
    }

    /// The palette for `game` (neutral until its artwork has been read).
    func palette(for game: Game) -> GamePalette {
        palettes[game.id] ?? .neutral
    }

    /// Reads the palettes of the hero games that don't have one yet.
    func loadPalettes() async {
        for slide in slides where palettes[slide.game.id] == nil {
            let url = slide.game.coverImagePath.map { URL(fileURLWithPath: $0) }
            palettes[slide.game.id] = await paletteExtractor.palette(forImageAt: url)
        }
    }

    /// A Continue card's quiet line: "{last played} · {playtime}" (single biggest source).
    func continueLine(for game: Game) -> String {
        let when = game.lastPlayedDate.map { LastPlayedPhrase.phrase(for: $0, now: now()) }
        let seconds = game.biggestRealPlaytimeSeconds
        let playtime = seconds > 0 ? DurationFormatting.playtime(seconds: seconds) : nil
        return [when, playtime].compactMap(\.self).joined(separator: " · ")
    }

    /// The label on the hero's primary button: "Keep playing" once there is playtime, else "Play".
    func playLabel(for game: Game) -> String {
        game.biggestRealPlaytimeSeconds > 0 ? "Keep playing" : "Play"
    }

    /// The art for a Continue tile: a wide hero or screenshot when there is one, else the cover.
    static func tileArtPath(for game: Game) -> String? {
        game.heroImagePath ?? game.carouselImagePaths.first ?? game.coverImagePath
    }
}
