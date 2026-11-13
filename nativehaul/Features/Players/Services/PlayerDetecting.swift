import Foundation

/// Finds the players on this Mac (the user's emulator apps and the nxnative engine). Live: ``LivePlayerDetector``;
/// mock: ``MockPlayerDetector``.
@MainActor
protocol PlayerDetecting: AnyObject {
    /// The emulator apps found, in catalog order.
    func detectedEmulators() -> [DetectedPlayer]
    /// The build engine in use (the Settings override, else the detected one), if its file exists.
    func detectedEngine() -> DetectedPlayer?
}

extension PlayerDetecting {
    /// Every player found: the emulators, then the engine.
    func detectedPlayers() -> [DetectedPlayer] {
        detectedEmulators() + [detectedEngine()].compactMap(\.self)
    }
}
