import Foundation

/// Hides and restores nativehaul's own windows (ADR 0030 Layer 1). Live: ``ApplicationVisibility``; mock:
/// ``MockAppVisibility``. Only ``unhide()`` brings nativehaul forward: couch mode uses it after a game has exited
/// (ADR 0058's amendment to ADR 0030), never while a game runs.
@MainActor
protocol AppVisibilityControlling: AnyObject {
    /// Takes every nativehaul window off screen.
    func hide()
    /// Puts nativehaul's windows back without taking the focus.
    func unhideWithoutActivation()
    /// Puts nativehaul's windows back in front (couch mode, after the game has exited).
    func unhide()
}
