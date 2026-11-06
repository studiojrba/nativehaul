import Foundation

/// Live ``AppBundleScanning`` using `FileManager`. Read-only: never modifies the folder.
struct AppBundleScanner: AppBundleScanning {
    private static let appExtension = "app"

    func scan(folder: String) throws -> [DiscoveredApp] {
        let fileManager = FileManager.default
        let root = URL(fileURLWithPath: BundlePath.normalize(folder), isDirectory: true)
        guard fileManager.fileExists(atPath: root.path) else { return [] }
        var results: [DiscoveredApp] = []
        let topLevel = try fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        for url in topLevel {
            if url.pathExtension == Self.appExtension {
                results.append(app(at: url))
            } else if (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                let nested = (try? fileManager.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )) ?? []
                results += nested.filter { $0.pathExtension == Self.appExtension }.map(app(at:))
            }
        }
        return results.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private func app(at url: URL) -> DiscoveredApp {
        DiscoveredApp(name: url.deletingPathExtension().lastPathComponent, path: BundlePath.normalize(url.path))
    }
}
