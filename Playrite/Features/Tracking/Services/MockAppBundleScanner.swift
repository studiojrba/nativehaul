import Foundation

/// Mock ``AppBundleScanning`` returning fixed results, optionally per folder.
struct MockAppBundleScanner: AppBundleScanning {
    /// Apps returned for folders without an entry in ``appsByFolder``.
    var apps: [DiscoveredApp] = [
        DiscoveredApp(name: "Tideborn", path: "/Users/demo/Switch/Games/Tideborn.app"),
        DiscoveredApp(name: "Moonwell", path: "/Users/demo/Switch/Games/Moonwell.app"),
    ]
    /// Apps per folder path (exact match).
    var appsByFolder: [String: [DiscoveredApp]] = [:]

    func scan(folder: String, options _: AppBundleScanOptions) throws -> [DiscoveredApp] {
        appsByFolder[folder] ?? apps
    }
}
