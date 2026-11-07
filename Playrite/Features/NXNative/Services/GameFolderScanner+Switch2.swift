import Foundation

/// Switch 2 summaries for ``GameFolderScanner``: a dump folder or `.nup` files, passed to the engine as they are.
extension GameFolderScanner {
    private static var titleTag: Regex<(Substring, Substring)> {
        /\[(04[0-9A-Fa-f]{14})\]/
    }

    private static var versionTag: Regex<(Substring, Substring)> {
        /\[v(\d+)\]/
    }

    /// A dump folder: whether the base game is there, its update versions and DLC count.
    func switch2Dump(_ folder: String) -> DetectedGame {
        let path: (String) -> String = { (folder as NSString).appendingPathComponent($0) }
        let hasBase = files.fileExists(atPath: path("base/exefs/main.npdm"))
            || files.fileExists(atPath: path("exefs/main.npdm"))
        let versions = ((try? files.contentsOfDirectory(atPath: path("updates"))) ?? [])
            .compactMap(Int.init).sorted()
        let dlcCount = ((try? files.contentsOfDirectory(atPath: path("dlc"))) ?? [])
            .count { !$0.hasPrefix(".") && files.isDirectory(atPath: path("dlc/\($0)")) }
        var parts = ["Switch 2", hasBase ? "base game" : "no base game folder"]
        if let newest = versions.last {
            parts.append(versions.count == 1 ? "update v\(newest)" : "\(versions.count) updates (newest v\(newest))")
        }
        if dlcCount > 0 {
            parts.append("\(dlcCount) DLC")
        }
        let folderName = (folder as NSString).lastPathComponent
        return DetectedGame(
            sourcePath: folder,
            name: PackageIdentityReader.gameName(fromFileName: folderName + ".dir"),
            titleID: folderName.firstMatch(of: Self.titleTag).map { String($0.1).uppercased() } ?? "",
            details: parts.joined(separator: " · "),
            isSwitch2: true
        )
    }

    /// One `.nup` container, queued as the file itself (so a folder of several never mixes them).
    func switch2Nup(_ path: String) -> DetectedGame {
        let name = (path as NSString).lastPathComponent
        let version = name.firstMatch(of: Self.versionTag).map { " · v\($0.1)" } ?? ""
        return DetectedGame(
            sourcePath: path,
            name: PackageIdentityReader.gameName(fromFileName: name),
            titleID: name.firstMatch(of: Self.titleTag).map { String($0.1).uppercased() } ?? "",
            details: "Switch 2 · .nup\(version)",
            isSwitch2: true
        )
    }

    /// The `.nup` files directly in a folder, in name order.
    func nupFiles(in folder: String) -> [String] {
        ((try? files.contentsOfDirectory(atPath: folder)) ?? [])
            .filter {
                !$0.hasPrefix("._") && ($0 as NSString).pathExtension.lowercased() == GameSourceShape.nupExtension
            }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
            .map { (folder as NSString).appendingPathComponent($0) }
    }
}
