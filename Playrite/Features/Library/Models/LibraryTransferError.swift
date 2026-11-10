import Foundation

/// Errors raised while importing or exporting the library.
enum LibraryTransferError: Error, Equatable, LocalizedError {
    /// The archive was written by a newer, unknown format.
    case unsupportedFormatVersion(Int)

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case let .unsupportedFormatVersion(version):
            "This library file uses format version \(version), which this version of NX Shelf cannot read."
        }
    }
}
