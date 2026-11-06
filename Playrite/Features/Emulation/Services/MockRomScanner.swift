import Foundation

/// Mock ``RomScanning`` returning fixed ROMs per folder.
struct MockRomScanner: RomScanning {
    /// ROMs keyed by folder.
    var romsByFolder: [String: [DiscoveredRom]] = [:]

    func scan(folder: String) -> [DiscoveredRom] {
        romsByFolder[folder] ?? []
    }
}
