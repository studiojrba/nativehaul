@testable import nativehaul

/// Records the interface sounds a view model asks for.
@MainActor
final class SoundRecorder {
    /// Sounds, in order.
    var sounds: [UISound] = []
}
