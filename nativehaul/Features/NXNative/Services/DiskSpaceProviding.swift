import Foundation

/// Reports free disk space. Live: ``VolumeDiskSpaceProvider``; mock: ``FixedDiskSpaceProvider``.
protocol DiskSpaceProviding: Sendable {
    /// Bytes available for important usage on the volume containing `path` (or its nearest existing ancestor).
    func availableBytes(atPath path: String) throws -> Int64
}
