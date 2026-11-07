import Foundation

/// Finds buildable game files in the builds inbox folder (ADR 0024, J.R's feature). Read-only.
///
/// Inputs are: package files loose in the folder (grouped by title ID, like a folder pick), `.nup` files loose in the
/// folder, and each subfolder that ``GameFolderScanner`` can build. Archives (`.zip`, `.rar`, …) are not inputs and
/// are never extracted; unfinished downloads, hidden items and apps are skipped. Items that can't be built (an update
/// without its base, …) are simply not offered.
struct BuildsInboxScanner: Sendable {
    private static let skippedFolderExtensions: Set = ["app"]

    private let files: any FileOperating

    /// Creates the scanner.
    init(files: any FileOperating) {
        self.files = files
    }

    /// Every buildable item in `folder`, loose files first, then subfolders in name order.
    func scan(_ folder: String) -> [DetectedGame] {
        let scanner = GameFolderScanner(files: files)
        let names = ((try? files.contentsOfDirectory(atPath: folder)) ?? [])
            .filter { !$0.hasPrefix(".") && !PartialDownload.isInProgress($0, in: folder, files: files) }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        let hasLoosePackages = names.contains { name in
            !files.isDirectory(atPath: (folder as NSString).appendingPathComponent(name))
                && StagedFileKind(pathExtension: (name as NSString).pathExtension) == .titleFile
        }
        var items = hasLoosePackages ? Self.games(in: scanner.scan(folder)).filter { !$0.isSwitch2 } : []
        items += scanner.nupFiles(in: folder)
            .filter { !PartialDownload.isInProgress(($0 as NSString).lastPathComponent, in: folder, files: files) }
            .map(scanner.switch2Nup)
        for name in names {
            let path = (folder as NSString).appendingPathComponent(name)
            guard files.isDirectory(atPath: path),
                  !Self.skippedFolderExtensions.contains((name as NSString).pathExtension.lowercased())
            else { continue }
            items += Self.games(in: scanner.scan(path))
        }
        return items
    }

    private static func games(in scan: GameFolderScan) -> [DetectedGame] {
        if case let .games(games, _) = scan {
            return games
        }
        return []
    }
}
