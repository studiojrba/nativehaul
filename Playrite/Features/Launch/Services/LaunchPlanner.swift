import Foundation

/// Pure rules for how a game launches.
///
/// Order: the tracked `.app` (playtime is recorded), then Steam (Mac) via `steam://rungameid/<id>`, then each CrossOver
/// bottle's Steam with `-applaunch <id>`. A Steam app ID with no detected install still offers Mac Steam
/// (Steam will offer to install). No bundle and no app ID → unavailable, with the reason.
@MainActor
enum LaunchPlanner {
    private static let steamRunScheme = "steam://rungameid/"
    private static let steamExe = "steam.exe"

    /// Launch options for `game`.
    static func availability(
        for game: Game,
        crossOver: CrossOverLaunchConfiguration = .standard,
        fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) -> LaunchAvailability {
        var options: [LaunchOption] = []
        var reasons: [String] = []
        if let path = game.appBundlePath {
            if fileExists(path) {
                options.append(LaunchOption(title: "Play", target: .application(path: path), isTracked: true))
            } else {
                reasons.append("The tracked app is missing at \(path).")
            }
        }
        if let appID = game.steamAppID {
            let installs = game.steamInstalls.isEmpty ? [SteamInstallLocation.mac] : game.steamInstalls
            options += installs.compactMap { steamOption(appID: appID, location: $0, crossOver: crossOver) }
        }
        if !options.isEmpty {
            return .available(options)
        }
        reasons.append("No tracked app and no Steam app ID. Track an .app or sync Steam to enable launching.")
        return .unavailable(reason: reasons.joined(separator: " "))
    }

    /// Target for launching Steam app `appID` from `location`.
    static func steamOption(
        appID: Int,
        location: SteamInstallLocation,
        crossOver: CrossOverLaunchConfiguration
    ) -> LaunchOption? {
        switch location.kind {
        case .mac:
            return URL(string: steamRunScheme + String(appID)).map {
                LaunchOption(title: location.displayName, target: .url($0), isTracked: false)
            }
        case .crossOver:
            guard let bottle = location.bottle, let steamRoot = location.steamRoot else { return nil }
            let bottlePath = bottlePath(containing: steamRoot)
            let exe = (steamRoot as NSString).appendingPathComponent(steamExe)
            let windowsExe = bottlePath.flatMap { WindowsPath.windowsPath(for: exe, inBottle: $0) } ?? exe
            return LaunchOption(
                title: location.displayName,
                target: .process(
                    executable: crossOver.wineExecutablePath,
                    arguments: crossOver.arguments(bottle: bottle, steamExe: windowsExe, appID: appID)
                ),
                isTracked: false
            )
        }
    }

    private static func bottlePath(containing path: String) -> String? {
        path.range(of: "/drive_c").map { String(path[..<$0.lowerBound]) }
    }
}
