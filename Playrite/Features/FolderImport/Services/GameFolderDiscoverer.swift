import Foundation

/// Walks configured folders and CrossOver locations off the main actor. Read-only.
struct GameFolderDiscoverer: Sendable {
    private let scanner: any AppBundleScanning
    private let crossOver: any CrossOverScanning
    private let locations: CrossOverLocations
    private let options: AppBundleScanOptions
    private let folderExists: @Sendable (String) -> Bool
    private let steamScanner: (any SteamInstallScanning)?
    private let steamRoots: SteamInstallRoots
    private let measuresBundles: Bool
    private let romScanner: (any RomScanning)?

    /// Creates the discoverer. `folderExists` is injectable so tests can use mock scanners with fake paths.
    init(
        scanner: any AppBundleScanning,
        crossOver: any CrossOverScanning,
        locations: CrossOverLocations = .standard,
        options: AppBundleScanOptions = .folderImport,
        folderExists: @escaping @Sendable (String) -> Bool = { FileManager.default.fileExists(atPath: $0) },
        steamScanner: (any SteamInstallScanning)? = nil,
        steamRoots: SteamInstallRoots = .standard,
        measuresBundles: Bool = false,
        romScanner: (any RomScanning)? = nil
    ) {
        self.scanner = scanner
        self.crossOver = crossOver
        self.locations = locations
        self.options = options
        self.folderExists = folderExists
        self.steamScanner = steamScanner
        self.steamRoots = steamRoots
        self.measuresBundles = measuresBundles
        self.romScanner = romScanner
    }

    /// Scans every folder plus CrossOver. Missing folders are reported, not thrown.
    func discover(folders: [String]) -> FolderDiscovery {
        var discovery = FolderDiscovery()
        for folder in folders {
            let expanded = (folder as NSString).expandingTildeInPath
            guard folderExists(expanded),
                  let apps = try? scanner.scan(folder: expanded, options: options)
            else {
                discovery.unreadableFolders.append(folder)
                continue
            }
            discovery.folderApps += apps
            discovery.roms += romScanner?.scan(folder: expanded) ?? []
        }
        let launchers = (locations.launchersFolder as NSString).expandingTildeInPath
        discovery.launcherApps = (try? scanner.scan(folder: launchers, options: options)) ?? []
        if measuresBundles {
            for app in discovery.folderApps + discovery.launcherApps {
                discovery.bundleSizes[app.path] = BundleSizeCalculator.size(ofBundleAt: app.path)
            }
        }
        discovery.crossOver = crossOver.scanBottles(at: locations.bottlesRoot)
        discovery.steamInstalls = steamScanner?.scanInstalls(roots: steamRoots)
        return discovery
    }
}
