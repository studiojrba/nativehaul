import Foundation

/// Mock ``DiskSpaceProviding`` returning a fixed value.
struct FixedDiskSpaceProvider: DiskSpaceProviding {
    /// Bytes to report.
    let bytes: Int64

    func availableBytes(atPath _: String) throws -> Int64 {
        bytes
    }
}
