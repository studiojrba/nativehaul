import Foundation

/// Mock ``SteamInstallScanning`` returning fixed installs.
struct MockSteamInstallScanner: SteamInstallScanning {
    private static let portal2 = 620
    private static let bottleSteam = "/Users/demo/Bottles/Steam/drive_c/Program Files (x86)/Steam"

    /// Installs to return.
    var installs: [SteamInstalledApp] = [
        SteamInstalledApp(appID: portal2, name: "Portal 2", sizeOnDisk: nil, location: .mac),
        SteamInstalledApp(
            appID: portal2,
            name: "Portal 2",
            sizeOnDisk: nil,
            location: .crossOver(
                bottle: "Steam",
                steamRoot: "/Users/demo/Bottles/Steam/drive_c/Program Files (x86)/Steam"
            )
        ),
    ]

    func scanInstalls(roots _: SteamInstallRoots) -> [SteamInstalledApp] {
        installs
    }
}
