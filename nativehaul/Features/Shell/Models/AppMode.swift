import Foundation

/// How nativehaul presents itself (spec §3.0): at the desk, or on the couch with a controller.
enum AppMode: String, Hashable, Sendable {
    /// Mouse and keyboard, the desktop shell.
    case desktop
    /// Controller-first, full screen (TV mode, ADR 0052; arrives in a later phase).
    case couch
}
