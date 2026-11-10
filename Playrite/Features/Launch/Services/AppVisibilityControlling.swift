import Foundation

/// Hides and restores NX Shelf's own windows (ADR 0030 Layer 1). Live: ``ApplicationVisibility``; mock:
/// ``MockAppVisibility``. Never activates NX Shelf.
@MainActor
protocol AppVisibilityControlling: AnyObject {
    /// Takes every NX Shelf window off screen.
    func hide()
    /// Puts NX Shelf's windows back without taking the focus.
    func unhideWithoutActivation()
}
