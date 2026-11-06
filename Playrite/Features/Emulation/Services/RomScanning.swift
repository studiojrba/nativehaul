import Foundation

/// Finds ROM files in a folder. Live: ``FileSystemRomScanner``; mock: ``MockRomScanner``. Read-only.
protocol RomScanning: Sendable {
    /// ROMs under `folder` whose system is known.
    func scan(folder: String) -> [DiscoveredRom]
}
