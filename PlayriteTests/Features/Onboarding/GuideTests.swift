import Foundation
@testable import Playrite
import Testing

/// ADR 0040: the guided tour, the Kriss way.
@MainActor
struct GuideTests {
    @Test func itStartsOnFirstLaunchOnlyAndWalksEveryStepInItsPlace() {
        let store = InMemoryOnboardingStore()
        let guide = OnboardingGuide(store: store)
        guide.startIfFirstRun()
        #expect(guide.currentStep == .welcome)
        var visited: [GuideDestination] = []
        while let step = guide.currentStep {
            visited.append(step.destination)
            guide.advance()
        }
        #expect(visited == [.home, .library, .gamePage, .builds, .steamSettings, .home])
        #expect(store.guideProgress == .finished)
        guide.startIfFirstRun()
        #expect(guide.currentStep == nil)
    }

    @Test func everyStepIsSkippableAndTheTourResumesWhereItWasLeft() {
        let store = InMemoryOnboardingStore(progress: .active(.library))
        let guide = OnboardingGuide(store: store)
        guide.skipStep()
        #expect(guide.currentStep == .gamePage)
        guide.exit()
        #expect(guide.currentStep == nil)
        #expect(guide.canResume)
        #expect(store.guideProgress == .paused(.gamePage))
        let later = OnboardingGuide(store: store)
        later.resume()
        #expect(later.currentStep == .gamePage)
    }

    @Test func usingTheHighlightedControlMovesTheTourOn() {
        let guide = OnboardingGuide(store: InMemoryOnboardingStore(progress: .active(.builds)))
        guide.didUse(.playNow)
        #expect(guide.currentStep == .builds)
        guide.didUse(.addBuildJob)
        #expect(guide.currentStep == .steam)
        #expect(GuideStep.allCases.compactMap(\.hotspot) == [.gameFolders, .playNow, .addBuildJob, .steamSignIn])
    }

    @Test func runSetupAgainStartsFromTheTopAndNoThanksPutsItAway() {
        let guide = OnboardingGuide(store: InMemoryOnboardingStore(progress: .paused(.steam)))
        guide.dismissForGood()
        #expect(!guide.canResume)
        guide.restart()
        #expect(guide.currentStep == .welcome)
    }

    @Test func progressIsRememberedAndTheOldSheetCountsAsFinished() throws {
        let defaults = try #require(UserDefaults(suiteName: "guide-tests-\(UUID().uuidString)"))
        let store = UserDefaultsOnboardingStore(defaults: defaults)
        #expect(store.guideProgress == .notStarted)
        store.guideProgress = .paused(.builds)
        #expect(UserDefaultsOnboardingStore(defaults: defaults).guideProgress == .paused(.builds))
        let legacy = try #require(UserDefaults(suiteName: "guide-legacy-\(UUID().uuidString)"))
        legacy.set(true, forKey: "onboarding.completed")
        #expect(UserDefaultsOnboardingStore(defaults: legacy).guideProgress == .finished)
    }

    @Test func linesAreShortAndOneIdeaAtATime() {
        for step in GuideStep.allCases {
            #expect(!step.lines.isEmpty && step.lines.count <= 3)
            #expect(step.lines.allSatisfy { $0.count <= 100 })
        }
    }

    @Test func typingRevealsTheLineOverTime() {
        #expect(TypingSchedule.visibleCount(elapsed: 0, length: 20) == 0)
        #expect(TypingSchedule.visibleCount(elapsed: 0.1, length: 20) == 4)
        #expect(TypingSchedule.visibleCount(elapsed: 10, length: 20) == 20)
        #expect(TypingSchedule.duration(length: 48) == 1)
    }
}
