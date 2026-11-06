import Foundation

/// Live ``DiskSpaceProviding`` using volume resource values.
struct VolumeDiskSpaceProvider: DiskSpaceProviding {
    func availableBytes(atPath path: String) throws -> Int64 {
        var url = URL(fileURLWithPath: path)
        while !FileManager.default.fileExists(atPath: url.path), url.pathComponents.count > 1 {
            url.deleteLastPathComponent()
        }
        let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        return values.volumeAvailableCapacityForImportantUsage ?? 0
    }
}
