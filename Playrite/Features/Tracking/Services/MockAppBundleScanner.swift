import Foundation

/// Mock ``AppBundleScanning`` returning fixed results.
struct MockAppBundleScanner: AppBundleScanning {
    /// Apps to return.
    var apps: [DiscoveredApp] = [
        DiscoveredApp(name: "Tideborn", path: "/Users/demo/Switch/Games/Tideborn.app"),
        DiscoveredApp(name: "Moonwell", path: "/Users/demo/Switch/Games/Moonwell.app"),
    ]

    func scan(folder _: String) throws -> [DiscoveredApp] {
        apps
    }
}
