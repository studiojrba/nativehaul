import Foundation
@testable import nativehaul
import SwiftUI
import Testing

/// Spec §1.4: Dark on first launch, a saved choice (Light included) wins, a change applies at once and is remembered.
@MainActor
struct AppearanceControllerTests {
    @Test func firstLaunchIsDarkAndAppliedImmediately() {
        let applier = RecordingAppearanceApplier()
        let controller = AppearanceController(store: InMemoryAppearanceStore(), applier: applier)
        #expect(controller.preference == .dark)
        #expect(controller.colorScheme == .dark)
        #expect(applier.applied == [.dark])
    }

    @Test func aSavedLightChoiceWins() {
        let controller = AppearanceController(
            store: InMemoryAppearanceStore(.light),
            applier: RecordingAppearanceApplier()
        )
        #expect(controller.preference == .light)
        #expect(controller.colorScheme == .light)
    }

    @Test func togglingSavesAndApplies() {
        let store = InMemoryAppearanceStore()
        let applier = RecordingAppearanceApplier()
        let controller = AppearanceController(store: store, applier: applier)
        controller.toggle()
        #expect(controller.preference == .light)
        #expect(store.stored == .light)
        #expect(applier.applied == [.dark, .light])
        controller.preference = .light
        #expect(applier.applied == [.dark, .light], "Setting the same choice changes nothing")
        controller.toggle()
        #expect(store.stored == .dark)
    }

    @Test func theUserDefaultsStoreRoundTrips() throws {
        let suite = "appearance-tests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = UserDefaultsAppearanceStore(defaults: defaults)
        #expect(store.load() == nil)
        #expect(AppearanceController.startingPreference(from: store) == .dark)
        store.save(.light)
        #expect(UserDefaultsAppearanceStore(defaults: defaults).load() == .light)
        #expect(AppearanceController.startingPreference(from: store) == .light)
    }

    @Test func preferencesMapToAppKitAndSwiftUI() {
        #expect(AppearancePreference.dark.appearanceName == .darkAqua)
        #expect(AppearancePreference.light.appearanceName == .aqua)
        #expect(AppearancePreference.light.toggled == .dark)
    }
}
