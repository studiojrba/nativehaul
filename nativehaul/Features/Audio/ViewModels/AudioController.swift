import Observation

/// The app's sound: the looping background music and the interface sounds, behind the listener's Settings choices
/// (audio brief, spec §5). Music starts once the main window is up (onboarding included, from its first screen —
/// 0.1.1 note 1), fades out while a game runs and comes back when the player returns.
@MainActor
@Observable
final class AudioController {
    /// The listener's choices; every change is saved and applied at once.
    var preferences: AudioPreferences {
        didSet {
            guard preferences != oldValue else { return }
            store.save(preferences)
            applyMusic()
        }
    }

    /// Whether the main window is up (the shell or onboarding).
    private(set) var isShellActive = false
    /// Whether a launched game is running (music stays out of its way).
    private(set) var isGameRunning = false

    @ObservationIgnored private let store: any AudioPreferencesStoring
    @ObservationIgnored private let music: any MusicPlaying
    @ObservationIgnored private let sounds: any UISoundPlaying

    /// Creates the controller.
    init(store: any AudioPreferencesStoring, music: any MusicPlaying, sounds: any UISoundPlaying) {
        self.store = store
        self.music = music
        self.sounds = sounds
        preferences = store.load()
    }

    /// Call when the main window appears (the shell or onboarding).
    func shellDidAppear() {
        isShellActive = true
        applyMusic()
    }

    /// Call when the main window goes away.
    func shellDidDisappear() {
        isShellActive = false
        applyMusic()
    }

    /// Call when a launched game starts or stops running.
    func gameRunningDidChange(_ isRunning: Bool) {
        isGameRunning = isRunning
        applyMusic()
    }

    /// Plays an interface sound, if interface sounds are on.
    func play(_ sound: UISound) {
        guard preferences.areUISoundsEnabled, !isGameRunning else { return }
        sounds.play(sound)
    }

    private var shouldPlayMusic: Bool {
        preferences.isMusicEnabled && isShellActive && !isGameRunning
    }

    private func applyMusic() {
        if shouldPlayMusic {
            if music.isPlaying {
                music.setVolume(preferences.musicVolume)
            } else {
                music.play(volume: preferences.musicVolume)
            }
        } else {
            music.fadeOutAndStop()
        }
    }
}

extension AudioController {
    /// A silent controller for previews.
    static var preview: AudioController {
        AudioController(store: InMemoryAudioPreferencesStore(), music: MockMusicPlayer(), sounds: MockUISoundPlayer())
    }
}
