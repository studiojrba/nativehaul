import Foundation

/// Top-level navigation destinations shown in the sidebar.
enum SidebarDestination: Hashable, Sendable {
    /// Home, the landing page: the hero, Jump Back In and Recently Added.
    case home
    /// A status-based library section.
    case library(LibrarySection)
    /// Series with recommended play order.
    case series
    /// Collections / compilations.
    case collections
    /// Statistics and badges.
    case stats
    /// Playtime tracking.
    case tracking
    /// Optional nxnative build module.
    case nxnative
}
