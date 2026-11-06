import Foundation
import Observation

/// Drives the first-run walkthrough: welcome → checklist → each checked module in order → done.
///
/// Onboarding is an accelerator, never a gate: it can be skipped in one click from the first screen, the app works
/// fully without it, and finishing or skipping is remembered so it never nags. It can be re-run from Settings.
@MainActor
@Observable
final class OnboardingViewModel {
    /// The reassurance shown on the checklist.
    static let reassurance = "You can run setup again later, so don't worry about getting everything now."

    /// Current screen.
    private(set) var step: OnboardingStep = .welcome
    /// Checked modules.
    var selected: Set<OnboardingModule>
    /// Modules offered in the checklist.
    let modules: [OnboardingModule]

    private let store: any OnboardingStoring
    private let status: any OnboardingStatusProviding
    private let onFinish: @MainActor () -> Void

    /// Creates the walkthrough. `onFinish` closes it.
    init(
        store: any OnboardingStoring,
        status: any OnboardingStatusProviding,
        modules: [OnboardingModule] = OnboardingModule.available,
        onFinish: @escaping @MainActor () -> Void = {}
    ) {
        self.store = store
        self.status = status
        self.modules = modules
        self.onFinish = onFinish
        selected = Set(modules.filter(\.isCheckedByDefault))
    }

    /// Checked modules in checklist order.
    var plannedModules: [OnboardingModule] {
        modules.filter(selected.contains)
    }

    /// Whether `module` is checked.
    func isSelected(_ module: OnboardingModule) -> Bool {
        selected.contains(module)
    }

    /// Checks or unchecks `module`.
    func toggle(_ module: OnboardingModule) {
        if selected.contains(module) {
            selected.remove(module)
        } else {
            selected.insert(module)
        }
    }

    /// "Set up later": closes immediately and never shows again unasked.
    func skipAll() {
        store.hasCompletedOnboarding = true
        onFinish()
    }

    /// Moves forward one screen.
    func next() {
        switch step {
        case .welcome:
            step = .checklist
        case .checklist:
            step = plannedModules.first.map(OnboardingStep.module) ?? .done
        case let .module(current):
            step = module(after: current).map(OnboardingStep.module) ?? .done
        case .done:
            finish()
        }
    }

    /// Moves back one screen.
    func back() {
        switch step {
        case .welcome: break
        case .checklist: step = .welcome
        case let .module(current): step = module(before: current).map(OnboardingStep.module) ?? .checklist
        case .done: step = plannedModules.last.map(OnboardingStep.module) ?? .checklist
        }
    }

    /// Position of the current module, for "Step 2 of 3".
    var moduleProgress: (index: Int, count: Int)? {
        guard case let .module(current) = step, let index = plannedModules.firstIndex(of: current) else { return nil }
        return (index + 1, plannedModules.count)
    }

    /// The Done screen's lines: set up first, then skipped (each skipped one says where to find it later).
    var outcomes: [OnboardingOutcome] {
        let lines = modules.map { OnboardingOutcome(module: $0, isSetUp: status.isSetUp($0)) }
        return lines.filter(\.isSetUp) + lines.filter { !$0.isSetUp }
    }

    /// Remembers completion and closes.
    func finish() {
        store.hasCompletedOnboarding = true
        onFinish()
    }

    private func module(after current: OnboardingModule) -> OnboardingModule? {
        guard let index = plannedModules.firstIndex(of: current), index + 1 < plannedModules.count else { return nil }
        return plannedModules[index + 1]
    }

    private func module(before current: OnboardingModule) -> OnboardingModule? {
        guard let index = plannedModules.firstIndex(of: current), index > 0 else { return nil }
        return plannedModules[index - 1]
    }
}
