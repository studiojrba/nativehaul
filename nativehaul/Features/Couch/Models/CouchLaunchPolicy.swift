import Foundation

/// How a game opens (ADR 0052, ADR 0058, TV plan Q1): desktop launches are untouched (``LaunchStyle/standard``); couch
/// launches go full screen unless the game's Manage sheet says "Open windowed".
enum CouchLaunchPolicy {
    /// The window style for a launch in `mode`.
    static func style(mode: AppMode, opensWindowed: Bool) -> LaunchStyle {
        switch mode {
        case .desktop: .standard
        case .couch: opensWindowed ? .windowed : .fullScreen
        }
    }
}
