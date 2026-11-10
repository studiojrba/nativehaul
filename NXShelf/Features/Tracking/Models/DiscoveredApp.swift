import Foundation

/// An `.app` bundle found while scanning a games folder.
struct DiscoveredApp: Equatable, Hashable, Sendable, Identifiable {
    /// Bundle filename without `.app`.
    let name: String
    /// Normalised absolute path to the bundle.
    let path: String
    /// Best title: `CFBundleDisplayName`, then `CFBundleName`, then ``name``.
    let title: String
    /// Whether a hidden native-port library folder sits next to the bundle (marks a Switch native port).
    let hasPortLibrarySibling: Bool
    /// The Switch title ID an nxnative build stamps into its bundle identifier (`org.nxnative.<id>`), if any.
    let switchTitleID: String?

    /// Creates a discovered app. `title` defaults to `name`.
    init(
        name: String,
        path: String,
        title: String? = nil,
        hasPortLibrarySibling: Bool = false,
        switchTitleID: String? = nil
    ) {
        self.name = name
        self.path = path
        self.title = title ?? name
        self.hasPortLibrarySibling = hasPortLibrarySibling
        self.switchTitleID = switchTitleID
    }

    /// Whether this is an nxnative-built Switch port (by its stamped title ID or its port library).
    var isSwitchPort: Bool {
        switchTitleID != nil || hasPortLibrarySibling
    }

    /// Identity for lists.
    var id: String {
        path
    }
}
