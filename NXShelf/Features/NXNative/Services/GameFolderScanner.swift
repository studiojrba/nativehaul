import Foundation

/// Folder-first Add Build (ADR 0023, J.R's requirement): reads one folder holding a mix of base
/// games, updates and DLC, and sorts it by title ID into games. Read-only; only file names and package headers.
///
/// Like nxnative, it looks at the folder's own files (not subfolders), and packages beside a Switch 2 dump win.
struct GameFolderScanner: Sendable {
    private struct Package {
        let fileName: String
        let identity: PackageIdentity?
    }

    /// File access (read-only use).
    let files: any FileOperating

    /// Scans a picked folder, or a lone `.nsp`/`.xci`/`.nup` file.
    func scan(_ path: String) -> GameFolderScan {
        guard files.isDirectory(atPath: path) else { return scanFile(path) }
        let packages = packages(in: path)
        if !packages.isEmpty {
            return scanPackages(packages, folder: path)
        }
        switch GameSourceShape.detect(path, files: files) {
        case .dumpFolder: return .games([switch2Dump(path)], notes: [])
        case .nup: return .games(nupFiles(in: path).map(switch2Nup), notes: [])
        default: return .failure(GameFolderScan.noGameFilesReason)
        }
    }

    /// Distinct base title IDs among a folder's packages (more than one means the engine must be told which game).
    func baseTitleIDs(inFolder folder: String) -> Set<String> {
        Set(packages(in: folder).compactMap { $0.identity?.titleID.baseID.hex })
    }

    private func scanFile(_ path: String) -> GameFolderScan {
        guard files.fileExists(atPath: path) else { return .failure(GameFolderScan.noGameFilesReason) }
        if (path as NSString).pathExtension.lowercased() == GameSourceShape.nupExtension {
            return .games([switch2Nup(path)], notes: [])
        }
        let name = (path as NSString).lastPathComponent
        guard StagedFileKind(pathExtension: (name as NSString).pathExtension) == .titleFile else {
            return .failure(GameFolderScan.noGameFilesReason)
        }
        let package = Package(fileName: name, identity: PackageIdentityReader(files: files).identity(ofPackageAt: path))
        if let identity = package.identity, identity.titleID.kind != .base {
            let what = identity.titleID.kind == .update ? "an update" : "DLC"
            return .failure("This file is \(what) for \(Self.label(package, baseID: identity.titleID.baseID)), not "
                + "its base game. Choose the base game's file, or the folder holding both.")
        }
        return .games([DetectedGame(
            sourcePath: path,
            name: PackageIdentityReader.gameName(fromFileName: name),
            titleID: package.identity?.titleID.hex ?? "",
            details: "Base game",
            isSwitch2: false
        )], notes: [])
    }

    private func packages(in folder: String) -> [Package] {
        let reader = PackageIdentityReader(files: files)
        return ((try? files.contentsOfDirectory(atPath: folder)) ?? [])
            .filter {
                !$0.hasPrefix("._") && StagedFileKind(pathExtension: ($0 as NSString).pathExtension) == .titleFile
            }
            .filter { !PartialDownload.isInProgress($0, in: folder, files: files) }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
            .map { Package(fileName: $0, identity: reader.identity(ofPackageAt: (folder as NSString)
                    .appendingPathComponent($0))) }
    }

    private func scanPackages(_ packages: [Package], folder: String) -> GameFolderScan {
        let unidentified = packages.filter { $0.identity == nil }
        var groups: [SwitchTitleID: [Package]] = [:]
        for package in packages {
            if let baseID = package.identity?.titleID.baseID {
                groups[baseID, default: []].append(package)
            }
        }
        var games: [DetectedGame] = []
        var orphans: [String] = []
        for baseID in groups.keys.sorted(by: { $0.value < $1.value }) {
            let group = groups[baseID] ?? []
            if let game = game(from: group, baseID: baseID, folder: folder) {
                games.append(game)
            } else {
                orphans.append(Self.orphanSentence(group, baseID: baseID))
            }
        }
        if games.isEmpty, let first = unidentified.first {
            return .games([unidentifiedGame(first, count: unidentified.count, folder: folder)], notes: orphans)
        }
        guard !games.isEmpty else { return .failure(orphans.joined(separator: " ")) }
        var notes = orphans.map { "Skipped: \($0)" }
        if !unidentified.isEmpty {
            notes.append(Self.unidentifiedNote(unidentified.count))
        }
        return .games(games, notes: notes)
    }

    private func unidentifiedGame(_ first: Package, count: Int, folder: String) -> DetectedGame {
        DetectedGame(
            sourcePath: folder,
            name: PackageIdentityReader.gameName(fromFileName: first.fileName),
            titleID: "",
            details: count == 1 ? "1 game file (sorted by the engine)" : "\(count) game files (sorted by the engine)",
            isSwitch2: false
        )
    }

    private static func unidentifiedNote(_ count: Int) -> String {
        count == 1 ? "1 file couldn't be identified by name; the engine sorts it when it builds."
            : "\(count) files couldn't be identified by name; the engine sorts them when it builds."
    }

    private func game(from group: [Package], baseID: SwitchTitleID, folder: String) -> DetectedGame? {
        guard let base = group.first(where: { $0.identity?.titleID.kind == .base }) else { return nil }
        let updates = group.filter { $0.identity?.titleID.kind == .update }
        let dlcCount = group.count { $0.identity?.titleID.kind == .dlc }
        var parts = ["Base game"]
        if !updates.isEmpty {
            let newest = updates.compactMap { $0.identity?.version }.max()
            parts.append(newest.map { "update v\($0)" } ?? "update")
        }
        if dlcCount > 0 {
            parts.append("\(dlcCount) DLC")
        }
        return DetectedGame(
            sourcePath: folder,
            name: PackageIdentityReader.gameName(fromFileName: base.fileName),
            titleID: baseID.hex,
            details: parts.joined(separator: " · "),
            isSwitch2: false
        )
    }

    private static func label(_ package: Package, baseID: SwitchTitleID) -> String {
        let name = PackageIdentityReader.gameName(fromFileName: package.fileName)
        return name.isEmpty ? baseID.hex : "\(name) (\(baseID.hex))"
    }

    private static func orphanSentence(_ group: [Package], baseID: SwitchTitleID) -> String {
        let hasUpdate = group.contains { $0.identity?.titleID.kind == .update }
        let dlcCount = group.count { $0.identity?.titleID.kind == .dlc }
        let what = [hasUpdate ? "an update" : nil, dlcCount > 0 ? "\(dlcCount) DLC" : nil].compactMap(\.self)
            .joined(separator: " and ")
        let label = group.first.map { label($0, baseID: baseID) } ?? baseID.hex
        return "This folder has \(what) for \(label) but not its base game."
    }
}
