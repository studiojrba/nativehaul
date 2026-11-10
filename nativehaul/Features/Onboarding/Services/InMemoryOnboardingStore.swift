import Foundation

/// Mock ``OnboardingStoring``.
@MainActor
final class InMemoryOnboardingStore: OnboardingStoring {
    var hasCompletedOnboarding: Bool

    /// Creates the store.
    init(hasCompletedOnboarding: Bool = false) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
