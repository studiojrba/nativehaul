import Foundation

/// Live ``CrossOverScanning`` using `FileManager`. Read-only.
///
/// Each subfolder of the bottles root is a bottle. Within `drive_c/Program Files` and
/// `drive_c/Program Files (x86)`, every top-level folder that survives ``CrossOverSkipList`` and contains a
/// plausible game `.exe` (up to ``executableSearchDepth`` levels down) is reported once.
struct CrossOverBottleScanner: CrossOverScanning {
    /// Program Files folders searched in each bottle.
    static let programFilesFolders = ["drive_c/Program Files", "drive_c/Program Files (x86)"]
    /// How deep inside an install folder to look for the game `.exe`.
    static let executableSearchDepth = 3

    func scanBottles(at bottlesRoot: String) -> CrossOverScanResult {
        let root = (bottlesRoot as NSString).expandingTildeInPath
        let bottles = subfolders(of: root).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        var installs: [CrossOverInstall] = []
        var seen = Set<String>()
        for bottle in bottles {
            let bottlePath = (root as NSString).appendingPathComponent(bottle)
            for programFiles in Self.programFilesFolders {
                let base = (bottlePath as NSString).appendingPathComponent(programFiles)
                for folder in subfolders(of: base) where !CrossOverSkipList.shouldSkipFolder(named: folder) {
                    let folderPath = (base as NSString).appendingPathComponent(folder)
                    let key = "\(bottle)/\(TitleNormalizer.key(for: folder))"
                    guard !seen.contains(key),
                          let exe = gameExecutable(in: folderPath, depth: 1)
                    else { continue }
                    seen.insert(key)
                    installs.append(CrossOverInstall(
                        name: folder,
                        bottle: bottle,
                        folderPath: folderPath,
                        executablePath: exe
                    ))
                }
            }
        }
        return CrossOverScanResult(bottles: bottles, installs: installs)
    }

    private func gameExecutable(in folder: String, depth: Int) -> String? {
        guard depth <= Self.executableSearchDepth,
              let entries = try? FileManager.default.contentsOfDirectory(atPath: folder)
        else { return nil }
        let sorted = entries.filter { !$0.hasPrefix(".") }.sorted()
        if let exe = sorted.first(where: CrossOverSkipList.isPlausibleGameExecutable) {
            return (folder as NSString).appendingPathComponent(exe)
        }
        for name in sorted where !CrossOverSkipList.shouldSkipFolder(named: name) {
            let path = (folder as NSString).appendingPathComponent(name)
            if isDirectory(path), let exe = gameExecutable(in: path, depth: depth + 1) {
                return exe
            }
        }
        return nil
    }

    private func subfolders(of path: String) -> [String] {
        let entries = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
        return entries.filter { !$0.hasPrefix(".") && isDirectory((path as NSString).appendingPathComponent($0)) }
    }

    private func isDirectory(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}
