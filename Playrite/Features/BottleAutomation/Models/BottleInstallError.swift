import Foundation

/// Why a one-click install stopped. Messages name the step and what to do.
enum BottleInstallError: Error, Equatable, LocalizedError {
    /// CrossOver isn't installed.
    case crossOverMissing
    /// The game's recipe forbids installing.
    case blocked(CompatibilityVerdict)
    /// Not enough free space.
    case insufficientSpace(required: Int64, available: Int64)
    /// A CrossOver tool failed.
    case commandFailed(step: String, exitCode: Int32)
    /// The bottle was created but has no `cxbottle.conf`.
    case bottleConfigMissing
    /// Steam's installer couldn't be downloaded.
    case steamInstallerDownloadFailed
    /// Steam's installer finished but `steam.exe` isn't there.
    case steamNotInstalled
    /// Nobody signed in to the bottle's Steam in time.
    case signInTimedOut
    /// The golden bottle isn't ready.
    case goldenBottleNotReady
    /// Steam's session didn't carry over and the download never started after the sign-in prompt.
    case signInNeededInBottle(String)
    /// Steam never started the download.
    case downloadNeverStarted
    /// The bundled recipe database is newer than this build.
    case unsupportedRecipeDatabase(Int)
    /// The user cancelled.
    case cancelled

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case .crossOverMissing: "CrossOver isn't installed."
        case let .blocked(verdict): "\(verdict.rating.displayName): \(verdict.reason)"
        case let .insufficientSpace(required, available):
            "Not enough free space: needs about \(Self.bytes(required)), \(Self.bytes(available)) available."
        case let .commandFailed(step, exitCode): "CrossOver couldn't \(step) (exit code \(exitCode))."
        case .bottleConfigMissing: "The new bottle has no settings file, so the game's settings couldn't be applied."
        case .steamInstallerDownloadFailed: "Steam's installer couldn't be downloaded. Check your connection."
        case .steamNotInstalled: "Steam's installer finished, but Steam isn't in the bottle."
        case .signInTimedOut:
            "Steam sign-in wasn't finished with the account linked in Retriever. Open Steam in the bottle, "
                + "sign in with that account, then try again."
        case .goldenBottleNotReady: "Steam in CrossOver isn't set up yet."
        case let .signInNeededInBottle(name):
            "Steam in “\(name)” still needs a sign-in. Open Steam there, sign in, then press Download again."
        case .downloadNeverStarted:
            "Steam didn't start the download. Check the Steam window in the bottle, then try again."
        case let .unsupportedRecipeDatabase(version): "The recipe database (format \(version)) needs a newer app."
        case .cancelled: "Cancelled."
        }
    }

    private static func bytes(_ value: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: value, countStyle: .file)
    }
}
