import Observation

/// Drives the floating sidebar's hover state from a test (ADR 0037, round 2.1).
@MainActor
@Observable
final class RailHoverProbe {
    /// Whether the panel is expanded, as if hovered.
    var isExpanded = false
}
