import AppKit
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// The main window: onboarding in place of the shell while it runs (ADR 0057), couch mode full screen in place of the
/// desktop while it is on (ADR 0058), otherwise the 0.1.0 desktop shell (``AppShellView``) around the current screen,
/// plus everything the window does that isn't visual — the playtime
/// watcher, automatic upkeep, library reloads, sheets and the file
/// importer/exporter driven by the menu bar, and alerts that wait while a game runs (ADR 0030).
struct RootView: View {
    /// App dependencies.
    let environment: AppEnvironment
    @State private var libraryViewModel: LibraryViewModel
    @State private var nxnativeViewModel: NXNativeViewModel
    @State private var buildsViewModel: BuildsViewModel
    @State private var homeViewModel: HomeViewModel
    @State private var shell: ShellViewModel
    @State private var couch: CouchViewModel
    @State private var isOnboarding: Bool
    @State private var onboarding: OnboardingChatViewModel?

    /// Creates the root view.
    init(environment: AppEnvironment) {
        self.environment = environment
        let libraryViewModel = environment.makeLibraryViewModel()
        _libraryViewModel = State(initialValue: libraryViewModel)
        let nxnativeViewModel = environment.makeNXNativeViewModel { libraryViewModel.reload() }
        _nxnativeViewModel = State(initialValue: nxnativeViewModel)
        let buildsViewModel = BuildsViewModel(
            queue: nxnativeViewModel,
            library: { libraryViewModel.games },
            paletteExtractor: environment.paletteExtractor
        )
        _buildsViewModel = State(initialValue: buildsViewModel)
        let homeViewModel = HomeViewModel(library: libraryViewModel, paletteExtractor: environment.paletteExtractor)
        _homeViewModel = State(initialValue: homeViewModel)
        let isFirstRun = !environment.onboarding.hasCompletedOnboarding
        _isOnboarding = State(initialValue: isFirstRun)
        _onboarding = State(initialValue: nil)
        let audio = environment.audio
        let shell = ShellViewModel(
            makeLaunch: environment.makeGameLaunchViewModel(for:),
            isAppActive: { NSApplication.shared.isActive },
            onNavigate: { audio.play(.navigate) },
            onBack: { audio.play(.back) }
        )
        _shell = State(initialValue: shell)
        _couch = State(initialValue: environment.makeCouchViewModel(
            home: homeViewModel,
            library: libraryViewModel,
            builds: buildsViewModel,
            isAppActive: { NSApplication.shared.isActive },
            exitToDesktop: { shell.exitCouch() }
        ))
    }

    var body: some View {
        Group {
            if let onboarding, isOnboarding, !environment.handoff.isGameRunning {
                OnboardingScreen(viewModel: onboarding)
            } else if shell.mode == .couch {
                CouchRootView(viewModel: couch)
            } else {
                AppShellView(
                    shell: shell,
                    games: libraryViewModel.games,
                    hasBuildInProgress: nxnativeViewModel.hasBuildInProgress,
                    appearance: environment.appearance
                ) {
                    screen
                }
            }
        }
        .background { WindowChromeView() }
        .onChange(of: isOnboarding, initial: true) { _, isOn in
            onboarding = isOn ? makeOnboarding() : nil
        }
        .environment(environment)
        .focusedSceneValue(\.shellViewModel, shell)
        .focusedSceneValue(\.libraryViewModel, libraryViewModel)
        .modifier(RootLifecycle(
            environment: environment,
            libraryViewModel: libraryViewModel,
            shell: shell,
            couch: couch,
            isOnboarding: $isOnboarding
        ))
        .modifier(RootPresentations(environment: environment, libraryViewModel: libraryViewModel, shell: shell))
    }

    @ViewBuilder private var screen: some View {
        switch shell.screen {
        case .home:
            HomeScreen(
                viewModel: homeViewModel,
                play: play,
                open: { shell.open(gameID: $0.id) },
                seeAll: { shell.go(to: .library) },
                addGame: { shell.isAddingGame = true }
            )
        case .library:
            LibraryScreen(
                viewModel: libraryViewModel,
                badge: badge(for:),
                open: { shell.open(gameID: $0.id) },
                play: play,
                addGame: { shell.isAddingGame = true }
            )
        case .detail:
            if let id = shell.detailGameID, let game = libraryViewModel.game(withID: id) {
                DetailPage(
                    environment: environment,
                    game: game,
                    library: { libraryViewModel.visibleGames },
                    badge: badge(for:),
                    back: { shell.back() },
                    play: { option in Task { await shell.play(game, option: option) } },
                    open: { shell.open(gameID: $0) },
                    openBuilds: { shell.openBuilds(focusing: game.switchTitleID) }
                )
            } else {
                Color.clear.onAppear { shell.detailGameDisappeared() }
            }
        case .builds:
            BuildsPage(viewModel: buildsViewModel, shell: shell)
        case .settings:
            SettingsPage(environment: environment)
        }
    }

    /// A fresh conversation (onboarding never resets prefs or the appearance; finishing returns to the shell).
    private func makeOnboarding() -> OnboardingChatViewModel {
        environment.makeOnboardingChatViewModel {
            isOnboarding = false
            Task { await libraryViewModel.runAutomaticUpkeep() }
        }
    }

    private func play(_ game: Game) {
        Task { await shell.play(game) }
    }

    private func badge(for game: Game) -> LibraryBuildBadge? {
        LibraryBuildBadge.badge(
            for: game,
            buildingTitleIDs: nxnativeViewModel.buildingTitleIDs,
            hasUpdate: environment.gameBadges.badge(for: game) != nil
        )
    }
}

#Preview {
    let environment = AppEnvironment.preview
    RootView(environment: environment)
        .modelContainer(environment.container)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
