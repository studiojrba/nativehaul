import Foundation

/// Live ``RomScanning``: walks a folder (up to four levels, skipping hidden items and app bundles) and keeps files
/// whose
/// system ``RomFileClassifier`` can tell.
struct FileSystemRomScanner: RomScanning {
    private static let maxDepth = 4

    func scan(folder: String) -> [DiscoveredRom] {
        let root = URL(fileURLWithPath: folder)
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return [] }
        var roms: [DiscoveredRom] = []
        let extensions = RomFileClassifier.extensions
        for case let url as URL in enumerator {
            if enumerator.level > Self.maxDepth {
                enumerator.skipDescendants()
                continue
            }
            guard extensions.contains(url.pathExtension.lowercased()) else { continue }
            let path = url.path(percentEncoded: false)
            guard let system = RomFileClassifier.system(forFileAt: path) else { continue }
            roms.append(DiscoveredRom(path: path, title: RomFileClassifier.title(forFileAt: path), system: system))
        }
        return roms.sorted { $0.path < $1.path }
    }
}
