import Foundation
@testable import nativehaul
import Testing

@MainActor
struct OnboardingViewModelTests {
    private func make(
        store: InMemoryOnboardingStore = InMemoryOnboardingStore(),
        status: FixedOnboardingStatus = FixedOnboardingStatus(),
        onFinish: @escaping @MainActor () -> Void = {}
    ) -> OnboardingViewModel {
        OnboardingViewModel(store: store, status: status, onFinish: onFinish)
    }

    @Test func startsWithWelcomeAndOnlyFindGamesChecked() {
        let viewModel = make()
        #expect(viewModel.step == .welcome)
        #expect(viewModel.selected == [.findGames])
        #expect(viewModel.modules.last == .emulators)
    }

    @Test func setUpLaterSkipsInOneClickAndIsRemembered() {
        let store = InMemoryOnboardingStore()
        var closed = false
        let viewModel = make(store: store) { closed = true }
        viewModel.skipAll()
        #expect(store.hasCompletedOnboarding)
        #expect(closed)
    }

    @Test func onlyCheckedModulesGetAStepInChecklistOrder() {
        let viewModel = make()
        viewModel.toggle(.switchPorts)
        viewModel.toggle(.emulators)
        viewModel.next()
        #expect(viewModel.step == .checklist)
        viewModel.next()
        #expect(viewModel.step == .module(.findGames))
        #expect(viewModel.moduleProgress?.index == 1)
        #expect(viewModel.moduleProgress?.count == 3)
        viewModel.next()
        #expect(viewModel.step == .module(.switchPorts))
        viewModel.next()
        #expect(viewModel.step == .module(.emulators))
        viewModel.next()
        #expect(viewModel.step == .done)
        viewModel.back()
        #expect(viewModel.step == .module(.emulators))
    }

    @Test func uncheckingEverythingGoesStraightToDone() {
        let viewModel = make()
        viewModel.toggle(.findGames)
        viewModel.next()
        viewModel.next()
        #expect(viewModel.step == .done)
        viewModel.back()
        #expect(viewModel.step == .checklist)
    }

    @Test func doneListsSetUpFirstThenSkippedAndFinishingIsRemembered() {
        let store = InMemoryOnboardingStore()
        let viewModel = make(store: store, status: FixedOnboardingStatus(setUp: [.switchPorts]))
        #expect(viewModel.outcomes.first == OnboardingOutcome(module: .switchPorts, isSetUp: true))
        #expect(viewModel.outcomes.dropFirst().allSatisfy { !$0.isSetUp })
        viewModel.finish()
        #expect(store.hasCompletedOnboarding)
    }

    @Test func liveStatusReadsEachFeaturesOwnState() {
        let folders = InMemoryGameFolderStore(["/Games"])
        let tracking = InMemoryTrackingPreferencesStore()
        let status = LiveOnboardingStatus(gameFolders: folders, tracking: tracking) { _ in false }
        #expect(status.isSetUp(.findGames))
        #expect(!status.isSetUp(.switchPorts))
        #expect(!status.isSetUp(.emulators))
    }
}
