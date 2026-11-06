import Foundation

/// Why a component check or install stopped.
enum ComponentError: Error, Equatable, LocalizedError {
    /// The catalog's format is newer than this build.
    case unsupportedCatalog(Int)
    /// The release has no Mac download.
    case noMacAsset
    /// The release feed couldn't be read.
    case releaseUnavailable
    /// The download's SHA-256 didn't match the published one.
    case checksumMismatch
    /// The download didn't contain the expected app.
    case appNotFound(String)
    /// A system tool failed.
    case toolFailed(String)
    /// There's nothing waiting for confirmation.
    case nothingToConfirm

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case let .unsupportedCatalog(version): "The component catalog (format \(version)) needs a newer app."
        case .noMacAsset: "The latest release has no Mac download."
        case .releaseUnavailable: "Couldn't check the official release. Try again later."
        case .checksumMismatch: "The download didn't match its published checksum, so it was not installed."
        case let .appNotFound(name): "The download didn't contain \(name)."
        case let .toolFailed(step): "macOS couldn't \(step)."
        case .nothingToConfirm: "There's nothing waiting to install."
        }
    }
}
