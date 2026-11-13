import Foundation

/// Launching from couch and the Resume/Close overlay (spec §3.7, TV plan Q1–Q3).
extension CouchViewModel {
    /// Plays a game: the launch phase in its wash, then the real handoff. Full screen unless the game's Manage sheet
    /// says "Open windowed". A game with no way to start opens its Detail, which says why.
    func play(gameID: UUID) async {
        guard let game = library.game(withID: gameID) else { return }
        let launch = services.makeLaunch(game)
        guard launch.primaryOption != nil else {
            openDetail(gameID)
            return
        }
        state.overlay = .launching(gameID)
        Task { await loadPalette(for: game) }
        let style = CouchLaunchPolicy.style(
            mode: .couch,
            opensWindowed: services.windowedLaunches.opensWindowed(gameID)
        )
        await launch.launch(nil, style: style)
        if let error = launch.errorMessage {
            state.overlay = .message(error)
        } else if !services.isAppActive(), state.overlay == .launching(gameID) {
            state.overlay = .none
        }
    }

    /// The game took over (nativehaul hid for it, or went to the background): the launch phase is done.
    func handoffCompleted() {
        if case .launching = state.overlay {
            state.overlay = .none
        }
    }

    /// nativehaul came forward (the Home button, through macOS Controller Shortcuts): while a game runs, offer
    /// Resume or Close.
    func appDidBecomeActive() {
        guard services.handoff.isGameRunning, state.overlay == .none else { return }
        state.overlay = .paused(.resume)
    }

    /// A game started or stopped running.
    func gameRunningDidChange(_ isRunning: Bool) {
        if isRunning {
            handoffCompleted()
            return
        }
        closeFlow.gameExited()
        switch state.overlay {
        case .paused, .closing, .forceQuitOffer: state.overlay = .none
        case .none, .launching, .message: break
        }
    }

    /// Resume: the game comes back in front and nativehaul steps aside again.
    func resumeGame() {
        guard let path = services.handoff.gamePath else { return }
        services.runningGames.activate(appAt: path)
        services.handoff.stepAside()
    }

    /// Runs the close flow's commands.
    func run(_ commands: [CloseGameCommand]) {
        for command in commands {
            switch command {
            case .terminate:
                services.handoff.gamePath.map { services.runningGames.terminate(appAt: $0) }
            case let .startTimer(attempt):
                Task { [sleep = services.sleep] in
                    await sleep(CouchInputTiming.gracefulCloseTimeout)
                    self.closeTimerElapsed(attempt: attempt)
                }
            case .offerForceQuit:
                state.overlay = .forceQuitOffer(.keepWaiting)
            case .forceTerminate:
                services.handoff.gamePath.map { services.runningGames.forceTerminate(appAt: $0) }
            }
        }
    }

    /// A close timer finished.
    func closeTimerElapsed(attempt: Int) {
        run(closeFlow.timerElapsed(attempt: attempt, isGameRunning: services.handoff.isGameRunning))
    }

    /// The game the overlay or launch phase is about.
    var sessionGame: Game? {
        if case let .launching(gameID) = state.overlay {
            return library.game(withID: gameID)
        }
        guard let path = services.handoff.gamePath else { return nil }
        let target = URL(fileURLWithPath: path).standardizedFileURL.path
        return library.games.first { game in
            game.appBundlePath.map { URL(fileURLWithPath: $0).standardizedFileURL.path == target } ?? false
        }
    }
}
