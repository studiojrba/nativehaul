import Foundation

/// Where one game's bottle and its Steam live.
struct BottlePlan: Equatable, Sendable {
    /// Bottle name (also its folder name).
    let bottleName: String
    /// macOS path of the bottle folder.
    let bottlePath: String

    /// macOS path of the bottle's Steam folder.
    var steamRoot: String {
        (bottlePath as NSString).appendingPathComponent("drive_c/Program Files (x86)/Steam")
    }

    /// Windows path of the bottle's `steam.exe`.
    var steamExecutable: String {
        "C:\\Program Files (x86)\\Steam\\steam.exe"
    }

    /// macOS path of the bottle's `cxbottle.conf`.
    var configPath: String {
        (bottlePath as NSString).appendingPathComponent("cxbottle.conf")
    }

    /// The provenance record for a game installed in this bottle (the same shape the folder scan records).
    var installLocation: SteamInstallLocation {
        .crossOver(bottle: bottleName, steamRoot: steamRoot)
    }
}
