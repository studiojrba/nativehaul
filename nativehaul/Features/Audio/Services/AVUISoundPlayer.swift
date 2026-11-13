import AVFoundation

/// Live ``UISoundPlaying``. Each sound has a small preloaded pool of players at one shared gain (the files' levels are
/// final, never re-normalised). A repeat inside ``minimumRepeatInterval`` is dropped, and a busy pool restarts its
/// oldest voice, so held-down navigation never stacks into distortion.
@MainActor
final class AVUISoundPlayer: UISoundPlaying {
    /// The one gain every interface sound plays at.
    static let sharedGain: Float = 1
    /// Repeats of the same sound closer together than this are dropped.
    static let minimumRepeatInterval: TimeInterval = 0.035
    private static let voicesPerSound = 3

    private var pools: [UISound: [AVAudioPlayer]] = [:]
    private var nextVoice: [UISound: Int] = [:]
    private var lastPlayed: [UISound: Date] = [:]

    /// Creates the player and preloads every sound.
    init() {
        for sound in UISound.allCases {
            pools[sound] = Self.makeVoices(for: sound)
        }
    }

    func play(_ sound: UISound) {
        let now = Date()
        if let last = lastPlayed[sound], now.timeIntervalSince(last) < Self.minimumRepeatInterval {
            return
        }
        guard let voices = pools[sound], !voices.isEmpty else { return }
        lastPlayed[sound] = now
        let index = (nextVoice[sound] ?? 0) % voices.count
        nextVoice[sound] = index + 1
        let voice = voices[index]
        voice.currentTime = 0
        voice.play()
    }

    private static func makeVoices(for sound: UISound) -> [AVAudioPlayer] {
        guard let url = Bundle.main.url(forResource: sound.resourceName, withExtension: UISound.resourceExtension)
        else { return [] }
        return (0 ..< voicesPerSound).compactMap { _ in
            let voice = try? AVAudioPlayer(contentsOf: url)
            voice?.volume = sharedGain
            voice?.prepareToPlay()
            return voice
        }
    }
}
