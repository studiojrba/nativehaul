import Foundation
import Observation

/// The Download panel for one game: whether one-click install is offered, the golden-bottle offer, and live progress.
@MainActor
@Observable
final class BottleInstallViewModel {
    /// CodeWeavers' CrossOver page.
    static let crossOverURL = URL(string: "https://www.codeweavers.com/crossover")

    /// The game.
    let game: Game
    /// The current install or setup stage, while one is running or just finished.
    private(set) var stage: BottleInstallStage?
    /// Whether the stage belongs to the golden-bottle setup (not the game's install).
    private(set) var isSettingUpSteam = false

    private let installer: any BottleInstalling
    private let onChanged: @MainActor () -> Void
    private var task: Task<Void, Never>?
    private var revision = 0

    /// Creates the view model. `onChanged` runs after a successful install.
    init(game: Game, installer: any BottleInstalling, onChanged: @escaping @MainActor () -> Void = {}) {
        self.game = game
        self.installer = installer
        self.onChanged = onChanged
    }

    /// Whether Download is offered, and if not, why.
    var availability: InstallAvailability {
        _ = revision
        return installer.availability(for: game)
    }

    /// Whether the panel has anything to show.
    var isVisible: Bool {
        stage != nil || availability != .notApplicable
    }

    /// Whether an install or setup is running.
    var isRunning: Bool {
        task != nil && stage?.isFinished == false
    }

    /// Whether the user needs to act in Steam's window.
    var isWaitingForUser: Bool {
        switch stage {
        case .waitingForSignIn, .needsSignInInBottle: true
        default: false
        }
    }

    /// One click: clone the golden bottle, apply the recipe, install the game.
    func download() {
        guard !isRunning else { return }
        isSettingUpSteam = false
        task = Task {
            await installer.install(game) { [weak self] in self?.stage = $0 }
            if stage == .installed {
                onChanged()
            }
            finish()
        }
    }

    /// Accepts the offer: sets up Steam in CrossOver once.
    func setUpSteam() {
        guard !isRunning else { return }
        isSettingUpSteam = true
        task = Task {
            await installer.setUpGoldenBottle { [weak self] in self?.stage = $0 }
            finish()
        }
    }

    /// Opens Steam in the relevant bottle so the user can sign in there.
    func openSteam() {
        installer.openSteam(for: isSettingUpSteam ? nil : game)
    }

    /// Stops waiting. The bottle is kept.
    func cancel() {
        task?.cancel()
    }

    /// Clears a finished stage so the panel shows the current availability again.
    func dismissResult() {
        guard stage?.isFinished == true else { return }
        stage = nil
        revision += 1
    }

    private func finish() {
        task = nil
        revision += 1
    }
}
