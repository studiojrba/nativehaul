import Foundation
import Observation

/// Settings → Game Folders: the configured folder list and the scan action.
@MainActor
@Observable
final class GameFoldersViewModel {
    /// Configured folders, in the order added.
    private(set) var folders: [String]
    /// Result of the most recent scan.
    private(set) var lastSummary: FolderImportSummary?
    /// Whether a scan is running.
    private(set) var isScanning = false
    /// Last error.
    private(set) var errorMessage: String?

    private let store: any GameFolderStoring
    private let importer: any GameFolderImporting
    private let onLibraryChanged: @MainActor () -> Void

    /// Creates the view model.
    init(
        store: any GameFolderStoring,
        importer: any GameFolderImporting,
        onLibraryChanged: @escaping @MainActor () -> Void = {}
    ) {
        self.store = store
        self.importer = importer
        self.onLibraryChanged = onLibraryChanged
        folders = store.load()
    }

    /// Adds folders chosen in the open panel, ignoring duplicates (after normalisation).
    func add(_ urls: [URL]) {
        var existing = Set(folders.map(BundlePath.normalize))
        for url in urls {
            let path = BundlePath.normalize(url.path)
            if existing.insert(path).inserted {
                folders.append(path)
            }
        }
        store.save(folders)
    }

    /// Adds folders and scans straight away, so their games are adopted without another click (ADR 0057).
    func addAndScan(_ urls: [URL]) async {
        add(urls)
        await scan()
    }

    /// Swaps `folder` for the one the user picked (same position in the list), then scans.
    func replace(_ folder: String, with url: URL) async {
        let path = BundlePath.normalize(url.path(percentEncoded: false))
        guard let index = folders.firstIndex(of: folder) else { return await addAndScan([url]) }
        if folders.contains(where: { BundlePath.normalize($0) == path }) {
            folders.remove(at: index)
        } else {
            folders[index] = path
        }
        store.save(folders)
        await scan()
    }

    /// Removes a folder from the list. Nothing on disk is touched.
    func remove(_ folder: String) {
        folders.removeAll { $0 == folder }
        store.save(folders)
    }

    /// Scans every game folder and records the summary.
    func scan() async {
        guard !isScanning else { return }
        isScanning = true
        defer { isScanning = false }
        do {
            lastSummary = try await importer.scanConfiguredFolders()
            errorMessage = nil
            onLibraryChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
