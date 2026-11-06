import Foundation

/// Live ``SteamInstallScanning``. Reads `appmanifest_*.acf` files from every Steam library folder:
/// Mac Steam's own library plus those listed in its `libraryfolders.vdf`, and the same for each CrossOver bottle's
/// Windows Steam (Windows paths such as `D:\Games` are resolved through the bottle's `dosdevices`).
struct SteamInstallScanner: SteamInstallScanning {
    private static let manifestPrefix = "appmanifest_"
    private static let manifestSuffix = ".acf"
    private static let libraryFile = "steamapps/libraryfolders.vdf"

    func scanInstalls(roots: SteamInstallRoots) -> [SteamInstalledApp] {
        let macRoot = expand(roots.macSteamRoot)
        var results = manifests(in: libraries(steamRoot: macRoot, resolve: { $0 }), location: .mac)
        let bottlesRoot = expand(roots.bottlesRoot)
        for bottle in subfolders(of: bottlesRoot) {
            let bottlePath = (bottlesRoot as NSString).appendingPathComponent(bottle)
            for folder in SteamInstallRoots.bottleSteamFolders {
                let steamRoot = (bottlePath as NSString).appendingPathComponent(folder)
                guard isDirectory(steamRoot) else { continue }
                let location = SteamInstallLocation.crossOver(bottle: bottle, steamRoot: steamRoot)
                let libraries = libraries(steamRoot: steamRoot) { WindowsPath.macPath(for: $0, inBottle: bottlePath) }
                results += manifests(in: libraries, location: location)
            }
        }
        return results.filter { !SteamInstallRoots.ignoredAppIDs.contains($0.appID) }
    }

    /// `steamapps` folders for a Steam root: its own plus any extra libraries, de-duplicated.
    private func libraries(steamRoot: String, resolve: (String) -> String?) -> [String] {
        let own = (steamRoot as NSString).appendingPathComponent("steamapps")
        let vdfPath = (steamRoot as NSString).appendingPathComponent(Self.libraryFile)
        let text = (try? String(contentsOfFile: vdfPath, encoding: .utf8)) ?? ""
        let extra = SteamKeyValues.values(forKey: "path", in: text)
            .compactMap(resolve)
            .map { ($0 as NSString).appendingPathComponent("steamapps") }
        var seen = Set<String>()
        return ([own] + extra).filter { isDirectory($0) && seen.insert(BundlePath.normalize($0)).inserted }
    }

    private func manifests(in libraries: [String], location: SteamInstallLocation) -> [SteamInstalledApp] {
        libraries.flatMap { library in
            let files = (try? FileManager.default.contentsOfDirectory(atPath: library)) ?? []
            return files
                .filter { $0.hasPrefix(Self.manifestPrefix) && $0.hasSuffix(Self.manifestSuffix) }
                .sorted()
                .compactMap { app(fromManifestAt: (library as NSString).appendingPathComponent($0), location: location)
                }
        }
    }

    private func app(fromManifestAt path: String, location: SteamInstallLocation) -> SteamInstalledApp? {
        guard let text = try? String(contentsOfFile: path, encoding: .utf8),
              let appID = SteamKeyValues.value(forKey: "appid", in: text).flatMap(Int.init)
        else { return nil }
        let name = SteamKeyValues.value(forKey: "name", in: text) ?? "Steam App \(appID)"
        let size = SteamKeyValues.value(forKey: "SizeOnDisk", in: text).flatMap(Int64.init)
        return SteamInstalledApp(appID: appID, name: name, sizeOnDisk: size, location: location)
    }

    private func expand(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }

    private func subfolders(of path: String) -> [String] {
        let entries = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
        return entries
            .filter { !$0.hasPrefix(".") && isDirectory((path as NSString).appendingPathComponent($0)) }
            .sorted()
    }

    private func isDirectory(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}
