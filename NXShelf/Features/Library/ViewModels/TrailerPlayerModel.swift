import AVFoundation
import Observation

/// Playback state for a streamed trailer (ADR 0038): it loops, starts muted, and can be paused and unmuted. A stream
/// that fails to load marks itself failed, and the slide falls back to the poster. Nothing is downloaded to disk.
@MainActor
@Observable
final class TrailerPlayerModel {
    /// The player the layer renders.
    let player = AVQueuePlayer()
    /// Whether sound is off (it starts off).
    private(set) var isMuted = true
    /// Whether it is playing.
    private(set) var isPlaying = false
    /// Whether the stream could not be played.
    private(set) var hasFailed = false
    @ObservationIgnored private var looper: AVPlayerLooper?
    @ObservationIgnored private var statusObservation: NSKeyValueObservation?

    /// Prepares `url` for looping playback, muted.
    init(url: URL) {
        player.isMuted = true
        let looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        statusObservation = looper.observe(\.status) { [weak self] looper, _ in
            guard looper.status == .failed else { return }
            Task { @MainActor in self?.markFailed() }
        }
        self.looper = looper
    }

    /// Starts or resumes playback.
    func play() {
        guard !hasFailed else { return }
        player.play()
        isPlaying = true
    }

    /// Pauses playback.
    func pause() {
        player.pause()
        isPlaying = false
    }

    /// Plays when paused, pauses when playing.
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    /// Turns sound on or off.
    func toggleMute() {
        isMuted.toggle()
        player.isMuted = isMuted
    }

    private func markFailed() {
        hasFailed = true
        pause()
    }
}
