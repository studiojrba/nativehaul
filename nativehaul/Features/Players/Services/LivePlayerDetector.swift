import Foundation

/// Live ``PlayerDetecting``: asks the ``EmulatorRouter`` where each catalog emulator is installed (reading the app's
/// own version), and resolves the engine the way the build pipeline does — the Settings override, else the standalone
/// nxnative found in the usual places (ADR 0021, ADR 0027).
@MainActor
final class LivePlayerDetector: PlayerDetecting {
    private let router: EmulatorRouter
    private let engineConfiguration: any EngineConfigurationStoring
    private let locator: NXNativeLocator
    private let files: any FileOperating
    private let readVersion: (String) -> String?

    /// Creates the detector. `readVersion` reads an app bundle's short version (default: its Info.plist).
    init(
        router: EmulatorRouter,
        engineConfiguration: any EngineConfigurationStoring,
        locator: NXNativeLocator,
        files: any FileOperating,
        readVersion: @escaping (String) -> String? = LivePlayerDetector.bundleVersion(atPath:)
    ) {
        self.router = router
        self.engineConfiguration = engineConfiguration
        self.locator = locator
        self.files = files
        self.readVersion = readVersion
    }

    func detectedEmulators() -> [DetectedPlayer] {
        EmulatorCatalog.profiles.compactMap { profile in
            router.appPath(for: profile).map { path in
                DetectedPlayer(
                    id: profile.id,
                    name: profile.name,
                    kind: .emulator(profileID: profile.id),
                    path: path,
                    version: readVersion(path)
                )
            }
        }
    }

    func detectedEngine() -> DetectedPlayer? {
        let configuration = engineConfiguration.load()
        let path = configuration.hasEngineOverride
            ? EngineConfiguration.expand(configuration.enginePath)
            : locator.detectedEngine()
        guard let path, files.fileExists(atPath: path) else { return nil }
        return DetectedPlayer(
            id: DetectedPlayer.engineID,
            name: DetectedPlayer.engineName,
            kind: .buildEngine,
            path: path,
            version: nil
        )
    }

    /// An app bundle's `CFBundleShortVersionString`, if it has one.
    nonisolated static func bundleVersion(atPath path: String) -> String? {
        Bundle(path: path)?.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
