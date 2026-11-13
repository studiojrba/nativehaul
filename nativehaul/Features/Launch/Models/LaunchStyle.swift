import Foundation

/// How a game's window should open (ADR 0052, ADR 0058). Desktop mode always uses ``standard``: the game decides,
/// exactly as before. Couch mode asks for ``fullScreen``, or ``windowed`` for games whose Manage sheet says
/// "Open windowed".
enum LaunchStyle: Equatable, Sendable {
    /// No preference: the game's own setting.
    case standard
    /// Ask the game to open full screen.
    case fullScreen
    /// Ask the game to open in a window.
    case windowed
}
