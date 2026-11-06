import Foundation

/// Top-level navigation destinations shown in the sidebar.
enum SidebarDestination: Hashable, Sendable {
    /// A status-based library section.
    case library(LibrarySection)
}
