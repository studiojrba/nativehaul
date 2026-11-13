import Foundation

extension AppEnvironment {
    /// Builds couch mode's state (ADR 0058) over the desktop's view models, so both share the library, the hero
    /// carousel and Builds. `isAppActive` reports whether nativehaul is frontmost; `exitToDesktop` hands the window
    /// back.
    func makeCouchViewModel(
        home: HomeViewModel,
        library: LibraryViewModel,
        builds: BuildsViewModel,
        isAppActive: @escaping @MainActor () -> Bool = { true },
        exitToDesktop: @escaping @MainActor () -> Void
    ) -> CouchViewModel {
        let services = CouchServices(
            input: couch.makeInput(),
            handoff: handoff,
            runningGames: couch.runningGames,
            modePreferences: modePreferences,
            windowedLaunches: windowedLaunches,
            paletteExtractor: paletteExtractor,
            makeLaunch: makeGameLaunchViewModel(for:),
            makeDetail: { game in
                self.makeDetailViewModel(for: game, buildBadge: { nil }, library: { library.visibleGames })
            },
            isAppActive: isAppActive,
            sleep: { try? await Task.sleep(for: .seconds($0)) },
            clock: { Date() },
            exitToDesktop: exitToDesktop
        )
        return CouchViewModel(
            home: home,
            library: library,
            builds: builds,
            audio: audio,
            appearance: appearance,
            services: services
        )
    }
}
