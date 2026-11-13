import Foundation
import Observation

/// Game Detail's state (spec §3.3), from the real library: the case's colours and palette, the copy and specs from
/// ``DetailFacts``, the favourite, Show in Finder, the build link and "Also on your shelf". Launching goes through
/// ``launch`` (all its states: options, needs-app, the user-file prompt, the reason it can't).
@MainActor
@Observable
final class DetailViewModel {
    /// The game.
    let game: Game
    /// Launch state for the game.
    let launch: GameLaunchViewModel
    /// The older detail state (playtime per source, sessions, status, HLTB, Manage).
    let details: GameDetailViewModel
    /// The game's palette (neutral until its artwork has been read).
    private(set) var palette = GamePalette.neutral
    /// Last error saving the favourite.
    private(set) var errorMessage: String?

    @ObservationIgnored private let repository: any LibraryRepository
    @ObservationIgnored private let revealer: any FileRevealing
    @ObservationIgnored private let paletteExtractor: any GamePaletteExtracting
    @ObservationIgnored private let buildBadge: @MainActor () -> LibraryBuildBadge?
    @ObservationIgnored private let library: @MainActor () -> [Game]
    @ObservationIgnored private let hltbSeconds: @MainActor () -> Int?
    @ObservationIgnored private let now: @MainActor () -> Date

    /// Creates Detail's state. `buildBadge` reports the game's real build badge; `library` lists the shelf for
    /// "Also on your shelf"; `hltbSeconds` the cached main-story estimate, if any.
    init(
        game: Game,
        launch: GameLaunchViewModel,
        details: GameDetailViewModel,
        repository: any LibraryRepository,
        revealer: any FileRevealing,
        paletteExtractor: any GamePaletteExtracting,
        buildBadge: @escaping @MainActor () -> LibraryBuildBadge? = { nil },
        library: @escaping @MainActor () -> [Game] = { [] },
        hltbSeconds: @escaping @MainActor () -> Int? = { nil },
        now: @escaping @MainActor () -> Date = { Date() }
    ) {
        self.game = game
        self.launch = launch
        self.details = details
        self.repository = repository
        self.revealer = revealer
        self.paletteExtractor = paletteExtractor
        self.buildBadge = buildBadge
        self.library = library
        self.hltbSeconds = hltbSeconds
        self.now = now
    }

    // MARK: Copy and specs

    /// "{genre} · {year}", if known.
    var eyebrow: String? {
        DetailFacts.eyebrow(for: game)
    }

    /// "{studio} — {year}" under the case, if known.
    var caption: String? {
        DetailFacts.caption(for: game)
    }

    /// The description, if the game has one.
    var summary: String? {
        let text = game.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    /// "Play" or "Start".
    var playLabel: String {
        DetailFacts.playLabel(for: game)
    }

    /// The build status, when the game has a build.
    var buildState: DetailBuildState? {
        DetailBuildState.state(for: game, badge: buildBadge())
    }

    /// The specs table.
    var specs: [DetailSpecRow] {
        DetailFacts.specs(for: game, build: buildState, hltbSeconds: hltbSeconds(), now: now())
    }

    /// The editorial note, once there is playtime.
    var editorialNote: String? {
        DetailFacts.editorialNote(for: game)
    }

    /// The game's screenshots.
    var screenshots: [String] {
        DetailFacts.screenshots(for: game)
    }

    /// "Also on your shelf".
    var relatedGames: [Game] {
        RelatedGames.games(for: game, in: library())
    }

    /// The turn button's suffix: "· or drag it · {playtime} played" (without the playtime before any play).
    var turnHint: String {
        let seconds = game.biggestRealPlaytimeSeconds
        guard seconds > 0 else { return "· or drag it" }
        return "· or drag it · \(DurationFormatting.playtime(seconds: seconds)) played"
    }

    // MARK: The case

    /// What is printed on the case.
    var caseArtwork: CaseArtwork {
        CaseArtwork.make(for: game, palette: palette)
    }

    /// Reads the palette from the cover art.
    func loadPalette() async {
        let url = game.coverImagePath.map { URL(fileURLWithPath: $0) }
        palette = await paletteExtractor.palette(forImageAt: url)
    }

    // MARK: Actions

    /// Whether the game is a favourite.
    var isFavorite: Bool {
        game.isFavorite
    }

    /// Marks or unmarks the game as a favourite, and saves.
    func toggleFavorite() {
        game.isFavorite.toggle()
        do {
            try repository.save()
            errorMessage = nil
        } catch {
            game.isFavorite.toggle()
            errorMessage = error.localizedDescription
        }
    }

    /// The file Show in Finder selects: the app, else the ROM.
    var finderPath: String? {
        game.appBundlePath ?? game.romPath
    }

    /// Shows the game's app or ROM in Finder.
    func showInFinder() {
        guard let finderPath else { return }
        revealer.reveal(path: finderPath)
    }
}
