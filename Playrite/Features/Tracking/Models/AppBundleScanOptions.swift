import Foundation

/// Limits for an ``AppBundleScanning`` walk.
struct AppBundleScanOptions: Equatable, Sendable {
    /// Shallow scan used by the tracking dashboard: the folder and one level of subfolders.
    static let tracking = AppBundleScanOptions(maxDepth: trackingDepth)
    /// Deep scan used by folder import (four levels below each configured folder).
    static let folderImport = AppBundleScanOptions(
        maxDepth: folderImportDepth,
        excludedBundlePaths: [Bundle.main.bundlePath]
    )

    /// Hidden sibling markers that identify a bundle as a Switch native port: Retriever's own, plus a marker older
    /// ports in users' game folders already carry (read-only recognition, so existing ports stay recognised).
    static let portLibraryFolderNames: Set = [".nx2apple-library", EngineConfiguration.defaultHiddenLibraryFolderName]
    /// Bundle filenames never imported (Playrite itself).
    static let excludedBundleNames: Set = ["Playrite.app"]

    /// Deepest level searched; items directly inside the root are level 1.
    var maxDepth: Int
    /// Bundles to skip, compared after normalisation.
    var excludedBundlePaths: [String] = []

    private static let trackingDepth = 2
    private static let folderImportDepth = 4
}
