import Foundation

/// Measures an `.app` bundle's size on disk (allocated bytes of every file inside). Read-only.
enum BundleSizeCalculator {
    private static let keys: Set<URLResourceKey> = [.totalFileAllocatedSizeKey, .isRegularFileKey]

    /// Total allocated bytes, or `nil` when the bundle cannot be read.
    static func size(ofBundleAt path: String) -> Int64? {
        guard let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: Array(keys),
            options: []
        ) else { return nil }
        var total: Int64 = 0
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: keys), values.isRegularFile == true else { continue }
            total += Int64(values.totalFileAllocatedSize ?? 0)
        }
        return total
    }
}
