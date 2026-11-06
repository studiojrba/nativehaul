import Foundation
import Observation

/// CrossOver setup outside any one game (onboarding): detects CrossOver and runs the one-time Steam-in-CrossOver
/// setup.
@MainActor
@Observable
final class GoldenBottleSetupViewModel {
    /// Setup progress, while running or just finished.
    private(set) var stage: BottleInstallStage?
    private let installer: any BottleInstalling
    private var revision = 0
    private var task: Task<Void, Never>?

    /// Creates the view model.
    init(installer: any BottleInstalling) {
        self.installer = installer
    }

    /// Current golden-bottle status.
    var status: GoldenBottleStatus {
        _ = revision
        return installer.goldenStatus()
    }

    /// Whether the setup is running.
    var isRunning: Bool {
        task != nil
    }

    /// Whether the user needs to sign in in Steam's window.
    var isWaitingForSignIn: Bool {
        stage == .waitingForSignIn
    }

    /// Accepts the offer.
    func setUp() {
        guard task == nil else { return }
        task = Task {
            await installer.setUpGoldenBottle { [weak self] in self?.stage = $0 }
            task = nil
            revision += 1
        }
    }

    /// Opens Steam in the golden bottle.
    func openSteam() {
        installer.openSteam(for: nil)
    }

    /// Re-checks (for example after installing CrossOver).
    func refresh() {
        revision += 1
    }
}
