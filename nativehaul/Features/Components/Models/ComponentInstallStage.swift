import Foundation

/// Progress of a component install or update.
enum ComponentInstallStage: Equatable, Sendable {
    /// Downloading from the official source.
    case downloading
    /// Checking the published SHA-256.
    case verifyingChecksum
    /// Unpacking the download.
    case unpacking
    /// Asking macOS about the app's signature.
    case checkingSignature
    /// Waiting for the user to approve, after seeing the signature status.
    case awaitingConfirmation(SignatureStatus)
    /// Copying into place.
    case installing
    /// Done.
    case installed(path: String)
    /// Stopped, with the reason.
    case failed(String)
}
