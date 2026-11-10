import Foundation

/// Tabs of the Settings window, so the tour can open the one it describes (ADR 0040).
enum SettingsTab: Hashable, Sendable {
    case general, steam, artwork, gameFolders, emulators, updates, tracking, nxnative
}
