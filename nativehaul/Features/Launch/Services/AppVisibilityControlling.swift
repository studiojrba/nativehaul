import Foundation

/// Hides and restores nativehaul's own windows (ADR 0030 Layer 1). Live: ``ApplicationVisibility``; mock:
/// ``MockAppVisibility``. Never activates nativehaul.
@MainActor
protocol AppVisibilityControlling: AnyObject {
    /// Takes every nativehaul window off screen.
    func hide()
    /// Puts nativehaul's windows back without taking the focus.
    func unhideWithoutActivation()
}
