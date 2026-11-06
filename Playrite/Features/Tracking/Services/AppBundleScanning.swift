import Foundation

/// Finds `.app` bundles in a folder. Live: ``AppBundleScanner``; mock: ``MockAppBundleScanner``.
protocol AppBundleScanning: Sendable {
    /// Returns `.app` bundles directly inside `folder` (and one level of subfolders), sorted by name.
    func scan(folder: String) throws -> [DiscoveredApp]
}
