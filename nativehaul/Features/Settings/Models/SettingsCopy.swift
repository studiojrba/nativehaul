import Foundation

/// The Settings page's fixed copy (spec §3.5), kept out of the views.
enum SettingsCopy {
    /// The page intro.
    static let intro = "Where the folders, players and keys live. Set it once, then forget all about it."
    /// The footer (spec §7 item 4: the real version, not Switch-only).
    static func footer(version: String) -> String {
        "nativehaul \(version) · for Switch ports and emulator classics on your Mac"
    }

    /// The music credit (audio brief, CC0; courtesy credit).
    static let musicCredit = "“The Charm 68” by The Cynic Project — cynicmusic.com / pixelsphere.org (CC0)"
}
