import Foundation

/// Live ``AppBundleScanning`` using `FileManager`. Read-only: never modifies the folder.
///
/// Rules: an `.app` bundle is a candidate and is never descended into; hidden items, anything inside the
/// Trash, symlinked folders and NX Shelf itself are skipped; the walk stops at ``AppBundleScanOptions/maxDepth``.
struct AppBundleScanner: AppBundleScanning {
    private static let appExtension = "app"
    private static let trashComponents: Set = [".Trash", ".Trashes"]
    private static let keys: [URLResourceKey] = [.isDirectoryKey, .isSymbolicLinkKey]

    func scan(folder: String, options: AppBundleScanOptions) throws -> [DiscoveredApp] {
        let root = BundlePath.normalize(folder)
        guard FileManager.default.fileExists(atPath: root), !Self.isInTrash(root) else { return [] }
        let excluded = Set(options.excludedBundlePaths.map(BundlePath.normalize))
        var results: [DiscoveredApp] = []
        try walk(URL(fileURLWithPath: root, isDirectory: true), depth: 1, options: options, excluded: excluded) {
            results.append($0)
        }
        return results.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// Whether `path` lies inside a Trash folder.
    static func isInTrash(_ path: String) -> Bool {
        path.split(separator: "/").contains { trashComponents.contains(String($0)) }
    }

    private func walk(
        _ directory: URL,
        depth: Int,
        options: AppBundleScanOptions,
        excluded: Set<String>,
        found: (DiscoveredApp) -> Void
    ) throws {
        guard depth <= options.maxDepth else { return }
        let entries = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Self.keys,
            options: []
        )
        let names = Set(entries.map(\.lastPathComponent))
        let hasPortLibrary = !names.isDisjoint(with: AppBundleScanOptions.portLibraryFolderNames)
        for url in entries where !url.lastPathComponent.hasPrefix(".") {
            let values = try? url.resourceValues(forKeys: Set(Self.keys))
            guard values?.isDirectory == true, values?.isSymbolicLink != true else { continue }
            if url.pathExtension == Self.appExtension {
                let path = BundlePath.normalize(url.path)
                let isExcluded = excluded.contains(path)
                    || AppBundleScanOptions.excludedBundleNames.contains(url.lastPathComponent)
                if !isExcluded {
                    found(app(at: url, path: path, hasPortLibrarySibling: hasPortLibrary))
                }
            } else {
                // Unreadable subfolders are skipped rather than failing the whole scan.
                try? walk(url, depth: depth + 1, options: options, excluded: excluded, found: found)
            }
        }
    }

    private func app(at url: URL, path: String, hasPortLibrarySibling: Bool) -> DiscoveredApp {
        let name = url.deletingPathExtension().lastPathComponent
        return DiscoveredApp(
            name: name,
            path: path,
            title: BundleTitleReader.title(ofBundleAt: url),
            hasPortLibrarySibling: hasPortLibrarySibling
        )
    }
}
