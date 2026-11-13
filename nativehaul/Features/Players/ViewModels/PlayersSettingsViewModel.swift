import Foundation
import Observation

/// Settings → Players (spec §3.5): the real players on this Mac. An emulator is the **default** when every system it
/// runs is routed to it (the router's real per-system choice, ADR 0057); "Make default" routes all of them to it. The
/// engine row carries the nxnative on/off switch and its path override. Nothing here is fabricated: a player shows only
/// when its file exists.
@MainActor
@Observable
final class PlayersSettingsViewModel {
    /// Emulator apps found.
    private(set) var emulators: [DetectedPlayer] = []
    /// The engine in use, when found.
    private(set) var engine: DetectedPlayer?

    private let detector: any PlayerDetecting
    private let router: EmulatorRouter
    private let engineConfiguration: any EngineConfigurationStoring
    private var revision = 0

    /// Creates the view model and detects at once.
    init(detector: any PlayerDetecting, router: EmulatorRouter, engineConfiguration: any EngineConfigurationStoring) {
        self.detector = detector
        self.router = router
        self.engineConfiguration = engineConfiguration
        refresh()
    }

    /// Detects again.
    func refresh() {
        emulators = detector.detectedEmulators()
        engine = detector.detectedEngine()
        revision += 1
    }

    /// Whether every system `player` runs is routed to it.
    func isDefault(_ player: DetectedPlayer) -> Bool {
        _ = revision
        guard let profile = player.profile, !profile.systems.isEmpty else { return false }
        return profile.systems.allSatisfy { router.profile(for: $0).id == profile.id }
    }

    /// Routes every system `player` runs to it (the catalog default is stored as "no override").
    func makeDefault(_ player: DetectedPlayer) {
        guard let profile = player.profile else { return }
        for system in profile.systems {
            let isCatalogDefault = EmulatorCatalog.defaultProfile(for: system).id == profile.id
            router.setProfile(isCatalogDefault ? nil : profile, for: system)
        }
        revision += 1
    }

    /// Whether Switch builds are on (on unless the user switched them off, ADR 0021).
    var isEngineEnabled: Bool {
        get {
            _ = revision
            return engineConfiguration.load().isEnabled
        }
        set {
            var configuration = engineConfiguration.load()
            configuration.isEnabled = newValue
            engineConfiguration.save(configuration)
            revision += 1
        }
    }

    /// Whether the engine path is the user's own choice rather than the detected one.
    var hasEngineOverride: Bool {
        _ = revision
        return engineConfiguration.load().hasEngineOverride
    }

    /// The engine row's sub-line: where it is, or the plain missing-file state.
    var engineDetail: String {
        guard let engine else { return Self.engineMissing }
        return hasEngineOverride ? "\(engine.detail) · \(Self.yourChoice)" : engine.detail
    }

    /// Uses the engine file the user picked (an override, ADR 0021).
    func chooseEngine(_ url: URL) {
        var configuration = engineConfiguration.load()
        configuration.enginePath = url.path(percentEncoded: false)
        engineConfiguration.save(configuration)
        refresh()
    }

    /// Drops the override so the detected engine is used.
    func useDetectedEngine() {
        var configuration = engineConfiguration.load()
        configuration.enginePath = ""
        engineConfiguration.save(configuration)
        refresh()
    }

    /// Shown when no engine file exists anywhere nativehaul looks.
    static let engineMissing = "Not found on this Mac — only needed to build Switch games"
    /// Marks a path the user chose.
    static let yourChoice = "your choice"
}
