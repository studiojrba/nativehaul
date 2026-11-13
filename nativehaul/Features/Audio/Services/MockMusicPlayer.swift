/// Recording ``MusicPlaying`` for previews and tests.
@MainActor
final class MockMusicPlayer: MusicPlaying {
    private(set) var isPlaying = false
    /// The last volume set.
    private(set) var volume: Double = 0
    /// How many times playback started.
    private(set) var playCount = 0

    /// Creates the mock.
    init() {}

    func play(volume: Double) {
        isPlaying = true
        self.volume = volume
        playCount += 1
    }

    func setVolume(_ volume: Double) {
        self.volume = volume
    }

    func fadeOutAndStop() {
        isPlaying = false
    }
}
