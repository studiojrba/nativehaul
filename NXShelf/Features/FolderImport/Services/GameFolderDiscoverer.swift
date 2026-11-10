import Foundation

/// Walks the scanned folders off the main actor: app bundles (including existing nxnative builds) and ROM files.
/// Read-only.
struct GameFolderDiscoverer: Sendable {
    private let scanner: any AppBundleScanning
    private let options: AppBundleScanOptions
    private let folderExists: @Sendable (String) -> Bool
    private let measuresBundles: Bool
    private let romScanner: (any RomScanning)?

    /// Creates the discoverer. `folderExists` is injectable so tests can use mock scanners with fake paths.
    init(
        scanner: any AppBundleScanning,
        options: AppBundleScanOptions = .folderImport,
        folderExists: @escaping @Sendable (String) -> Bool = { FileManager.default.fileExists(atPath: $0) },
        measuresBundles: Bool = false,
        romScanner: (any RomScanning)? = nil
    ) {
        self.scanner = scanner
        self.options = options
        self.folderExists = folderExists
        self.measuresBundles = measuresBundles
        self.romScanner = romScanner
    }

    /// Scans every folder. Missing folders are reported, not thrown.
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
        if measuresBundles {
            for app in discovery.folderApps {
                discovery.bundleSizes[app.path] = BundleSizeCalculator.size(ofBundleAt: app.path)
            }
        }
        return discovery
    }
}
