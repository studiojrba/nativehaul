import Foundation
@testable import nativehaul
import Testing

/// The onboarding status service (kept from the first-run walkthrough): each module reads its feature's own state.
@MainActor
struct OnboardingStatusTests {
    @Test func liveStatusReadsEachFeaturesOwnState() {
        let folders = InMemoryGameFolderStore(["/Games"])
        let tracking = InMemoryTrackingPreferencesStore()
        let status = LiveOnboardingStatus(gameFolders: folders, tracking: tracking) { _ in false }
        #expect(status.isSetUp(.findGames))
        #expect(!status.isSetUp(.switchPorts))
        #expect(!status.isSetUp(.emulators))
    }

    @Test func theUserDefaultsStoreRemembersCompletion() throws {
        let defaults = try #require(UserDefaults(suiteName: "OnboardingStatusTests"))
        defaults.removePersistentDomain(forName: "OnboardingStatusTests")
        let store = UserDefaultsOnboardingStore(defaults: defaults)
        #expect(!store.hasCompletedOnboarding)
        store.hasCompletedOnboarding = true
        #expect(UserDefaultsOnboardingStore(defaults: defaults).hasCompletedOnboarding)
    }
}
