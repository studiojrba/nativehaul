import Foundation

/// ``AudioOutputReading`` with a fixed answer, for previews and tests.
@MainActor
final class FixedAudioOutputReader: AudioOutputReading {
    private let name: String?

    /// Creates the reader.
    init(name: String? = "TV Speakers") {
        self.name = name
    }

    func currentOutputName() -> String? {
        name
    }
}
