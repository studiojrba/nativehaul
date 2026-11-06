import Foundation

/// A Steam app found installed on disk via its `appmanifest_<id>.acf`.
struct SteamInstalledApp: Equatable, Hashable, Sendable {
    /// Steam app ID.
    let appID: Int
    /// Name from the manifest.
    let name: String
    /// `SizeOnDisk` in bytes, when present.
    let sizeOnDisk: Int64?
    /// Which Steam client holds it.
    let location: SteamInstallLocation
}
