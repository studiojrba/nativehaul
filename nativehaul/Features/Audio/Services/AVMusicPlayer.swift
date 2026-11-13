import AVFoundation

/// Live ``MusicPlaying``: loops the bundled `charm-loop.m4a` (its last 8s are crossfaded into its first 8s, so a plain
/// loop is seamless) with `AVAudioPlayer`.
@MainActor
final class AVMusicPlayer: MusicPlaying {
    private static let resourceName = "charm-loop"
    private static let resourceExtension = "m4a"
    private static let fadeInSeconds: TimeInterval = 1.5
    private static let fadeOutSeconds: TimeInterval = 1.2
    private static let loopForever = -1

    private var player: AVAudioPlayer?
    private var stopTask: Task<Void, Never>?

    var isPlaying: Bool {
        player?.isPlaying == true && stopTask == nil
    }

    /// Creates the player. The file loads lazily on first play.
    init() {}

    func play(volume: Double) {
        stopTask?.cancel()
        stopTask = nil
        guard let player = loadedPlayer() else { return }
        if !player.isPlaying {
            player.volume = 0
            player.play()
        }
        player.setVolume(Float(volume), fadeDuration: Self.fadeInSeconds)
    }

    func setVolume(_ volume: Double) {
        guard stopTask == nil else { return }
        player?.volume = Float(volume)
    }

    func fadeOutAndStop() {
        guard let player, player.isPlaying, stopTask == nil else { return }
        player.setVolume(0, fadeDuration: Self.fadeOutSeconds)
        stopTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.fadeOutSeconds))
            guard !Task.isCancelled, let self else { return }
            self.player?.pause()
            stopTask = nil
        }
    }

    private func loadedPlayer() -> AVAudioPlayer? {
        if let player {
            return player
        }
        guard let url = Bundle.main.url(forResource: Self.resourceName, withExtension: Self.resourceExtension),
              let loaded = try? AVAudioPlayer(contentsOf: url)
        else { return nil }
        loaded.numberOfLoops = Self.loopForever
        loaded.prepareToPlay()
        player = loaded
        return loaded
    }
}
