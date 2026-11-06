import Foundation

/// Top-level navigation destinations shown in the sidebar.
enum SidebarDestination: Hashable, Sendable {
    /// A status-based library section.
    case library(LibrarySection)
    /// Series with recommended play order.
    case series
    /// Collections / compilations.
    case collections
    /// Steam provider dashboard.
    case steam
    /// Playtime tracking.
    case tracking
}
