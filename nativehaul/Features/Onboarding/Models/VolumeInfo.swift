import Foundation

/// A mounted volume, as the install step shows it (spec §3.6 disk scene): real name, capacity and free space.
struct VolumeInfo: Equatable, Sendable {
    /// The volume's name ("Macintosh HD").
    let name: String
    /// Where it is mounted ("/", "/Volumes/Fast SSD").
    let mountPath: String
    /// Bytes free for important use.
    let freeBytes: Int64
    /// Total capacity in bytes.
    let totalBytes: Int64

    /// Share of the volume in use, 0…1.
    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return min(1, max(0, 1 - Double(freeBytes) / Double(totalBytes)))
    }

    /// Whole gigabytes free (decimal, as Finder counts).
    var freeGigabytes: Int {
        Int(freeBytes / Self.bytesPerGigabyte)
    }

    /// Where nativehaul would put builds on this volume when it is an external drive.
    var installFolder: String {
        (mountPath as NSString).appendingPathComponent(AppInfo.productName)
    }

    private static let bytesPerGigabyte: Int64 = 1_000_000_000
}
