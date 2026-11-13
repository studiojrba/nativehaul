import Foundation

/// Mock ``PlayerDetecting`` with a fixed set of players, for previews and tests.
@MainActor
final class MockPlayerDetector: PlayerDetecting {
    /// Emulators to report.
    var emulators: [DetectedPlayer]
    /// Engine to report.
    var engine: DetectedPlayer?

    /// Creates the mock.
    init(emulators: [DetectedPlayer] = [], engine: DetectedPlayer? = nil) {
        self.emulators = emulators
        self.engine = engine
    }

    func detectedEmulators() -> [DetectedPlayer] {
        emulators
    }

    func detectedEngine() -> DetectedPlayer? {
        engine
    }

    /// A preview set: two emulators and the engine.
    static var preview: MockPlayerDetector {
        MockPlayerDetector(
            emulators: [
                DetectedPlayer(
                    id: EmulatorCatalog.retroArch.id,
                    name: EmulatorCatalog.retroArch.name,
                    kind: .emulator(profileID: EmulatorCatalog.retroArch.id),
                    path: "/Applications/RetroArch.app",
                    version: "1.19.1"
                ),
                DetectedPlayer(
                    id: EmulatorCatalog.dolphin.id,
                    name: EmulatorCatalog.dolphin.name,
                    kind: .emulator(profileID: EmulatorCatalog.dolphin.id),
                    path: "/Applications/Dolphin.app",
                    version: "2409"
                ),
            ],
            engine: DetectedPlayer(
                id: DetectedPlayer.engineID,
                name: DetectedPlayer.engineName,
                kind: .buildEngine,
                path: "/Users/demo/Switch/nxnative",
                version: nil
            )
        )
    }
}
