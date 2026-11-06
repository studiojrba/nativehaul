import Foundation

/// How the downloaded file holds the app.
enum ComponentInstallMethod: String, Codable, Sendable {
    /// A disk image: mount read-only, copy the `.app`, unmount.
    case dmg
    /// A `.zip` archive.
    case zip
    /// A `.tar.xz` / `.tar.gz` archive.
    case tar
}
