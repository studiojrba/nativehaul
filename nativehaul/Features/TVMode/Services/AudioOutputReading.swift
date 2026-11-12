import Foundation

/// Reads the current audio output's name for the TV menu (ADR 0052). Live: ``CoreAudioOutputReader``; mock:
/// ``FixedAudioOutputReader``. TV mode only shows it; changing outputs stays in macOS.
@MainActor
protocol AudioOutputReading: AnyObject {
    /// The default output device's name, if it can be read.
    func currentOutputName() -> String?
}
