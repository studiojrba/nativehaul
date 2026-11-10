import Foundation

/// Where to look for Steam installs.
struct SteamInstallRoots: Equatable, Sendable {
    /// Standard per-user locations.
    static let standard = SteamInstallRoots(
        macSteamRoot: "~/Library/Application Support/Steam",
        bottlesRoot: CrossOverLocations.standard.bottlesRoot
    )

    /// Mac Steam's data folder (holds `steamapps/`).
    var macSteamRoot: String
    /// CrossOver bottles folder.
    var bottlesRoot: String

    /// Where Windows Steam usually lives inside a bottle.
    static let bottleSteamFolders = ["drive_c/Program Files (x86)/Steam", "drive_c/Program Files/Steam"]
    /// Tools and runtimes that appear as installed apps but are not games.
    static let ignoredAppIDs: Set = [
        steamworksRedistributables, steamLinuxRuntime, steamLinuxRuntimeSoldier, steamLinuxRuntimeSniper,
    ]

    private static let steamworksRedistributables = 228_980
    private static let steamLinuxRuntime = 1_070_560
    private static let steamLinuxRuntimeSoldier = 1_391_110
    private static let steamLinuxRuntimeSniper = 1_628_350
}
