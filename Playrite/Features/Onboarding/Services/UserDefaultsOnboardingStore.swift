import Foundation

/// Live ``OnboardingStoring`` in `UserDefaults`.
@MainActor
final class UserDefaultsOnboardingStore: OnboardingStoring {
    private static let key = "onboarding.completed"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Self.key) }
        set { defaults.set(newValue, forKey: Self.key) }
    }
}
