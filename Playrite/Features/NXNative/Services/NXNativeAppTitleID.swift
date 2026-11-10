import Foundation

/// Reads the Switch title ID that nxnative stamps into a built app's bundle identifier (`org.nxnative.<title id>`),
/// for ports imported from a folder rather than built through Retriever (ADR 0038).
enum NXNativeAppTitleID {
    private static let prefix = "org.nxnative."

    /// The title ID of the app at `path`, or `nil` when it isn't an nxnative build.
    static func titleID(ofAppAt path: String?) -> String? {
        guard let path else { return nil }
        return Bundle(path: path)?.bundleIdentifier.flatMap(titleID(fromBundleIdentifier:))
    }

    /// The title ID inside a bundle identifier, or `nil` when it isn't an nxnative one.
    static func titleID(fromBundleIdentifier identifier: String) -> String? {
        guard identifier.lowercased().hasPrefix(prefix) else { return nil }
        return SwitchTitleID(identifier.dropFirst(prefix.count))?.hex
    }
}
