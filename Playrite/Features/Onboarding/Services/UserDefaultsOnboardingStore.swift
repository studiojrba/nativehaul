import Foundation

/// Live ``OnboardingStoring`` in `UserDefaults`. A user who finished or skipped the old first-run sheet counts as
/// having finished the tour, so it never appears unasked for them.
@MainActor
final class UserDefaultsOnboardingStore: OnboardingStoring {
    private static let progressKey = "onboarding.guide.progress"
    private static let legacyCompletedKey = "onboarding.completed"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var guideProgress: GuideProgress {
        get {
            let saved = defaults.data(forKey: Self.progressKey)
                .flatMap { try? JSONDecoder().decode(GuideProgress.self, from: $0) }
            if let saved {
                return saved
            }
            return defaults.bool(forKey: Self.legacyCompletedKey) ? .finished : .notStarted
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Self.progressKey)
        }
    }
}
