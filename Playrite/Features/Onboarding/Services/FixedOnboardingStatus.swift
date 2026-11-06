import Foundation

/// Mock ``OnboardingStatusProviding`` with a fixed set of set-up modules.
@MainActor
final class FixedOnboardingStatus: OnboardingStatusProviding {
    /// Modules reported as set up.
    var setUp: Set<OnboardingModule>

    /// Creates the mock.
    init(setUp: Set<OnboardingModule> = []) {
        self.setUp = setUp
    }

    func isSetUp(_ module: OnboardingModule) -> Bool {
        setUp.contains(module)
    }
}
