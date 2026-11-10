import Foundation

/// Reads a bundle's user-facing title from `Contents/Info.plist` without loading the bundle.
enum BundleTitleReader {
    private static let displayNameKey = "CFBundleDisplayName"
    private static let nameKey = "CFBundleName"

    /// `CFBundleDisplayName`, else `CFBundleName`, else `nil` (caller falls back to the filename).
    static func title(ofBundleAt url: URL) -> String? {
        let plistURL = url.appendingPathComponent("Contents/Info.plist")
        guard let data = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else { return nil }
        return [displayNameKey, nameKey]
            .compactMap { plist[$0] as? String }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }
}
