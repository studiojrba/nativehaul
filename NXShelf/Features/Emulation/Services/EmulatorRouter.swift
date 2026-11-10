import Foundation

/// Routes emulated games to the emulator app that owns them — NX Shelf is the shelf and the router, never the engine
/// (ADR 0019). Detection and argument building only; nothing is bundled or downloaded.
@MainActor
final class EmulatorRouter {
    private let preferences: any EmulatorPreferencesStoring
    private let files: any FileOperating
    private let appFolders: [String]

    /// Creates the router. Emulator apps are looked for in `appFolders` (default: /Applications, ~/Applications).
    init(
        preferences: any EmulatorPreferencesStoring,
        files: any FileOperating,
        appFolders: [String] = ["/Applications", "~/Applications"]
    ) {
        self.preferences = preferences
        self.files = files
        self.appFolders = appFolders.map { ($0 as NSString).expandingTildeInPath }
    }

    /// The profile used for `system`: the override when set (and valid), otherwise the default.
    func profile(for system: EmulatedSystem) -> EmulatorProfile {
        let chosen = preferences.profileID(for: system).flatMap(EmulatorCatalog.profile(id:))
        guard let chosen, chosen.systems.contains(system) else { return EmulatorCatalog.defaultProfile(for: system) }
        return chosen
    }

    /// Chooses an emulator for a system (`nil` restores the default).
    func setProfile(_ profile: EmulatorProfile?, for system: EmulatedSystem) {
        preferences.setProfileID(profile?.id, for: system)
    }

    /// Where `profile`'s app is installed, if anywhere.
    func appPath(for profile: EmulatorProfile) -> String? {
        appFolders.map { ($0 as NSString).appendingPathComponent(profile.appName) }
            .first { files.isDirectory(atPath: $0) }
    }

    /// How to launch an emulated game, or the honest reason it can't be yet.
    func availability(for game: Game) -> LaunchAvailability {
        guard let system = game.emulatedSystem, let romPath = game.romPath else {
            return .unavailable(reason: "This entry has no ROM file.")
        }
        guard files.fileExists(atPath: romPath)
        else { return .unavailable(reason: "The ROM is missing at \(romPath).") }
        let profile = profile(for: system)
        guard let appPath = appPath(for: profile) else {
            return .needsApp(reason: "\(profile.name) isn't installed.", helpURL: profile.homepage)
        }
        var corePath: String?
        if profile.usesCores, let core = system.retroArchCore {
            let path = EmulatorCatalog.corePath(core)
            guard files.fileExists(atPath: path) else {
                return .unavailable(reason: "\(profile.name) doesn't have its \(system.displayName) core yet. "
                    + "In \(profile.name), open Online Updater → Core Downloader and get “\(core)”.")
            }
            corePath = path
        }
        if let request = missingBios(profile, system: system) {
            return .needsUserFile(request)
        }
        return .available([LaunchOption(
            title: "Play in \(profile.name)",
            target: .applicationWithArguments(path: appPath, arguments: profile.arguments(
                romPath: romPath,
                corePath: corePath
            )),
            isTracked: true,
            trackedAppPath: appPath
        )])
    }

    private func missingBios(_ profile: EmulatorProfile, system: EmulatedSystem) -> UserFileRequest? {
        guard let bios = profile.biosRequirement, bios.systems.contains(system) else { return nil }
        return UserFilePlacer.isProvided(bios.request, files: files) ? nil : bios.request
    }

    /// After an emulator is installed, routes to it every system whose current emulator isn't installed
    /// (zero-tinker: installing is enough, no settings to change).
    func adoptInstalled(_ profile: EmulatorProfile) {
        for system in profile.systems where appPath(for: self.profile(for: system)) == nil {
            setProfile(profile, for: system)
        }
    }

    /// Places a file the user provided (a BIOS) where the emulator expects it.
    func provide(_ path: String, for request: UserFileRequest) throws -> UserFilePlacer.Outcome {
        try UserFilePlacer.place(path, for: request, files: files)
    }
}
