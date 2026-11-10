import Foundation
import Observation

/// The guided tour (ADR 0040). Shared by the main window and Settings, so a step can move between them. Every step is
/// skippable, the tour can be exited at any point and resumed where it left off, and nothing in it is required to use
/// the app (ADR 0016).
@MainActor
@Observable
final class OnboardingGuide {
    /// Where the tour stands.
    private(set) var progress: GuideProgress {
        didSet { store.guideProgress = progress }
    }

    private let store: any OnboardingStoring

    /// Creates the guide over a store.
    init(store: any OnboardingStoring) {
        self.store = store
        progress = store.guideProgress
    }

    /// The step showing, or `nil`.
    var currentStep: GuideStep? {
        if case let .active(step) = progress {
            step
        } else {
            nil
        }
    }

    /// Whether an exited tour can be resumed.
    var canResume: Bool {
        if case .paused = progress {
            true
        } else {
            false
        }
    }

    /// Starts the tour on first launch only.
    func startIfFirstRun() {
        if progress == .notStarted {
            progress = .active(.welcome)
        }
    }

    /// Starts again from the beginning ("Run setup again").
    func restart() {
        progress = .active(.welcome)
    }

    /// Picks up where an exited tour left off.
    func resume() {
        if case let .paused(step) = progress {
            progress = .active(step)
        }
    }

    /// Moves to the next step (finishing after the last).
    func advance() {
        guard let step = currentStep else { return }
        progress = step.next.map(GuideProgress.active) ?? .finished
    }

    /// Skips this step without doing it.
    func skipStep() {
        advance()
    }

    /// Leaves the tour for now; it can be resumed later.
    func exit() {
        if let step = currentStep {
            progress = .paused(step)
        }
    }

    /// Ends the tour for good (until "Run setup again").
    func dismissForGood() {
        progress = .finished
    }

    /// The user used a highlighted control: doing the step moves the tour on.
    func didUse(_ hotspot: GuideHotspot) {
        if currentStep?.hotspot == hotspot {
            advance()
        }
    }
}
