import Foundation
@testable import nativehaul
import Testing

@MainActor
struct AudioControllerTests {
    private func makeController(
        _ preferences: AudioPreferences = AudioPreferences()
    ) -> (AudioController, MockMusicPlayer, MockUISoundPlayer, InMemoryAudioPreferencesStore) {
        let store = InMemoryAudioPreferencesStore(preferences)
        let music = MockMusicPlayer()
        let sounds = MockUISoundPlayer()
        return (AudioController(store: store, music: music, sounds: sounds), music, sounds, store)
    }

    @Test func defaultsAreOnWithMusicAtSixTenths() {
        let preferences = AudioPreferences()
        #expect(preferences.isMusicEnabled)
        #expect(preferences.areUISoundsEnabled)
        #expect(preferences.musicVolume == 0.6)
    }

    @Test func musicWaitsForTheShell() {
        let (controller, music, _, _) = makeController()
        #expect(!music.isPlaying)
        controller.shellDidAppear()
        #expect(music.isPlaying)
        #expect(music.volume == 0.6)
    }

    @Test func musicStopsForAGameAndResumesAfter() {
        let (controller, music, _, _) = makeController()
        controller.shellDidAppear()
        controller.gameRunningDidChange(true)
        #expect(!music.isPlaying)
        controller.gameRunningDidChange(false)
        #expect(music.isPlaying)
    }

    @Test func turningMusicOffStopsItAndIsSaved() {
        let (controller, music, _, store) = makeController()
        controller.shellDidAppear()
        controller.preferences.isMusicEnabled = false
        #expect(!music.isPlaying)
        #expect(!store.preferences.isMusicEnabled)
    }

    @Test func volumeChangesApplyToThePlayingLoop() {
        let (controller, music, _, store) = makeController()
        controller.shellDidAppear()
        controller.preferences.musicVolume = 0.25
        #expect(music.volume == 0.25)
        #expect(music.playCount == 1)
        #expect(store.preferences.musicVolume == 0.25)
    }

    @Test func interfaceSoundsRespectTheToggle() {
        let (controller, _, sounds, _) = makeController()
        controller.play(.navigate)
        controller.preferences.areUISoundsEnabled = false
        controller.play(.confirm)
        #expect(sounds.played == [.navigate])
    }

    @Test func interfaceSoundsStayQuietWhileAGameRuns() {
        let (controller, _, sounds, _) = makeController()
        controller.gameRunningDidChange(true)
        controller.play(.back)
        #expect(sounds.played.isEmpty)
    }

    @Test func everySoundIsBundled() {
        for sound in UISound.allCases {
            #expect(Bundle.main.url(forResource: sound.resourceName, withExtension: UISound.resourceExtension) != nil)
        }
        #expect(Bundle.main.url(forResource: "charm-loop", withExtension: "m4a") != nil)
    }
}
