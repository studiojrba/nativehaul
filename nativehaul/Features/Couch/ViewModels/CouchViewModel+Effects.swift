import Foundation

/// Carrying out what ``CouchNavigator`` asks for.
extension CouchViewModel {
    /// Applies one effect.
    func apply(_ effect: CouchEffect) {
        switch effect {
        case let .sound(sound): play(sound)
        case .previousHero: home.carousel.previous()
        case .nextHero: home.carousel.next()
        case .playHero: heroGame.map { startPlay($0.id) }
        case .openHeroDetails: heroGame.map { openDetail($0.id) }
        case let .play(gameID): startPlay(gameID)
        case let .openDetails(gameID): openDetail(gameID)
        case let .toast(toast): show(toast)
        default: applyScreenEffect(effect)
        }
    }

    private func applyScreenEffect(_ effect: CouchEffect) {
        switch effect {
        case .exitToDesktop: services.exitToDesktop()
        case let .selectBuild(index): buildJobs[safe: index].map { builds.select($0) }
        case let .openBuild(index): openBuild(index)
        case let .setting(row, change): changeSetting(row, change)
        case .toggleFavorite: detail?.toggleFavorite()
        case .resumeGame: resumeGame()
        case .closeGame: run(closeFlow.request())
        case .forceQuitGame: run(closeFlow.forceQuit())
        case .keepWaiting: run(closeFlow.keepWaiting())
        default: break
        }
    }

    /// A click on the hero case (spec §3.7): plays the hero when it has focus, otherwise focuses it.
    func heroCaseClicked() {
        if state.screen == .home, state.area == .content, state.home.row == CouchHomeFocus.heroRow {
            heroGame.map { startPlay($0.id) }
        } else {
            state.area = .content
            state.home.row = CouchHomeFocus.heroRow
        }
    }

    /// The hero's live game.
    var heroGame: Game? {
        let slides = home.slides
        return slides.indices.contains(home.carousel.shown) ? slides[home.carousel.shown].game : nil
    }

    /// Opens a game's couch Detail.
    func openDetail(_ gameID: UUID) {
        guard let game = library.game(withID: gameID) else { return }
        CouchNavigator.openDetail(&state, gameID: gameID)
        if detail?.game.id != gameID {
            detail = services.makeDetail(game)
        }
        Task { await loadPalette(for: game) }
    }

    /// Reads `game`'s palette once.
    func loadPalette(for game: Game) async {
        guard palettes[game.id] == nil else { return }
        let url = game.coverImagePath.map { URL(fileURLWithPath: $0) }
        palettes[game.id] = await services.paletteExtractor.palette(forImageAt: url)
    }

    private func play(_ sound: UISound) {
        audio.play(sound)
        guard isRumbleEnabled else { return }
        switch sound {
        case .navigate: services.input.rumble(.light)
        case .confirm: services.input.rumble(.firm)
        case .back: break
        }
    }

    private func startPlay(_ gameID: UUID) {
        if isRumbleEnabled {
            services.input.rumble(.firm)
        }
        Task { await play(gameID: gameID) }
    }

    private func openBuild(_ index: Int) {
        guard let job = buildJobs[safe: index] else { return }
        if let game = builds.game(for: job) {
            openDetail(game.id)
        } else {
            show(.message("Not on your shelf yet"))
        }
    }
}
