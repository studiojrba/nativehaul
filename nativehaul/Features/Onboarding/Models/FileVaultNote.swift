import Foundation

/// The FileVault trade-off shown beside the couch choice (TV plan Q4): inform only, recommend it on, never change it.
enum FileVaultNote {
    /// The note's title.
    static let title = "A note on FileVault"

    /// The note for the Mac's real status.
    static func text(for status: FileVaultStatus) -> String {
        switch status {
        case .on:
            "FileVault is on, which we recommend: encryption protects your Mac if it’s lost or stolen. It does mean "
                + "you type your password when the Mac starts. With it off, the Mac can start straight into "
                + "nativehaul. It’s your choice, in System Settings → Privacy & Security."
        case .off:
            "FileVault is off, so the Mac can start straight into nativehaul. We recommend turning it on — "
                + "encryption protects your Mac if it’s lost or stolen — though you’d then type your password at "
                + "startup. It’s your choice, in System Settings → Privacy & Security."
        case .unknown:
            "With FileVault on (recommended — encryption protects your Mac if it’s lost or stolen) you type your "
                + "password at startup; with it off, the Mac can start straight into nativehaul. It’s your choice, "
                + "in System Settings → Privacy & Security."
        }
    }
}
