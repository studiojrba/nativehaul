import Foundation

/// Finds `.app` bundles in a folder. Live: ``AppBundleScanner``; mock: ``MockAppBundleScanner``.
protocol AppBundleScanning: Sendable {
    /// Returns `.app` bundles under `folder` within `options`, sorted by name.
    ///
    /// Never descends into a bundle once found, skips hidden items, the Trash and NX Shelf itself.
    func scan(folder: String, options: AppBundleScanOptions) throws -> [DiscoveredApp]
}

extension AppBundleScanning {
    /// Shallow scan (``AppBundleScanOptions/tracking``).
    func scan(folder: String) throws -> [DiscoveredApp] {
        try scan(folder: folder, options: .tracking)
    }
}
