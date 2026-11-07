import Foundation

/// What a Switch package file is: its title ID and, when known, its version (ADR 0023).
struct PackageIdentity: Equatable, Sendable {
    /// The package's own title ID (base, update or DLC).
    let titleID: SwitchTitleID
    /// The `vN` version, when the file name or metadata says.
    let version: Int?
}
