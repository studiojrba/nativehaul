import Foundation

/// Works out a game's update badge per source (see ``GameUpdateBadge``). Read-only.
@MainActor
struct GameUpdateBadgeProvider {
    private let files: any FileOperating
    private let switchVersions: SwitchTitleVersions
    private let macSteamRoot: String

    /// Creates the provider.
    init(files: any FileOperating, switchVersions: SwitchTitleVersions, roots: SteamInstallRoots = .standard) {
        self.files = files
        self.switchVersions = switchVersions
        macSteamRoot = (roots.macSteamRoot as NSString).expandingTildeInPath
    }

    /// The badge for `game`, if any.
    func badge(for game: Game) -> GameUpdateBadge? {
        switch game.platform {
        case .emulated:
            nil
        case .switchPort:
            switchBadge(for: game)
        case .steam, .macNative, .other:
            game.steamAppID.flatMap { steamBadge(appID: $0, installs: game.steamInstalls) }
        }
    }

    /// Steam badge from the first install's appmanifest that has one.
    func steamBadge(appID: Int, installs: [SteamInstallLocation]) -> GameUpdateBadge? {
        for root in steamRoots(for: installs) {
            let path = (root as NSString).appendingPathComponent("steamapps/appmanifest_\(appID).acf")
            guard let data = try? files.readData(atPath: path), let text = String(bytes: data, encoding: .utf8),
                  let flags = SteamKeyValues.value(forKey: "StateFlags", in: text).flatMap(Int.init)
            else { continue }
            let state = SteamAppState(rawValue: flags)
            if !state.isDisjoint(with: [.downloading, .updateRunning]) {
                return .steamDownloading(fraction: AppManifestStatus(manifest: text)?.fraction)
            }
            if !state.isDisjoint(with: [.updateRequired, .updatePaused, .updateStarted]) {
                return .steamUpdatePending
            }
            return nil
        }
        return nil
    }

    private func switchBadge(for game: Game) -> GameUpdateBadge? {
        guard let titleID = game.switchTitleID?.uppercased(), let built = game.switchVersion,
              let entry = switchVersions.titles[titleID], entry.latestVersion > built
        else { return nil }
        return .switchUpdateAvailable(latest: entry.displayVersion)
    }

    private func steamRoots(for installs: [SteamInstallLocation]) -> [String] {
        installs.compactMap { install in
            switch install.kind {
            case .mac: macSteamRoot
            case .crossOver: install.steamRoot
            }
        }
    }
}
