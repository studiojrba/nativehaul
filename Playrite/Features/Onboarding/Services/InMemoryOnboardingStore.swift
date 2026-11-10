import Foundation

/// Mock ``OnboardingStoring``.
@MainActor
final class InMemoryOnboardingStore: OnboardingStoring {
    var guideProgress: GuideProgress

    /// Creates the store.
    init(progress: GuideProgress = .notStarted) {
        guideProgress = progress
    }
}
