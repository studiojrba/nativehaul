import Foundation

/// Hides and restores Retriever's own windows (ADR 0030 Layer 1). Live: ``ApplicationVisibility``; mock:
/// ``MockAppVisibility``. Never activates Retriever.
@MainActor
protocol AppVisibilityControlling: AnyObject {
    /// Takes every Retriever window off screen.
    func hide()
    /// Puts Retriever's windows back without taking the focus.
    func unhideWithoutActivation()
}
