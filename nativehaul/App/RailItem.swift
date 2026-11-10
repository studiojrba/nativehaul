import Foundation

/// One entry in the icon rail.
struct RailItem: Identifiable, Hashable, Sendable {
    /// Destination it selects.
    let destination: SidebarDestination
    /// Label shown when the rail is expanded.
    let title: String
    /// SF Symbol name.
    let symbolName: String

    /// Identity.
    var id: SidebarDestination {
        destination
    }

    /// Rail contents, top to bottom, grouped by section.
    static let groups: [[RailItem]] = [
        [RailItem(destination: .home, title: "Home", symbolName: "house")]
            + LibrarySection.allCases.map { RailItem(
                destination: .library($0),
                title: $0.title,
                symbolName: $0.symbolName
            ) },
        [
            RailItem(destination: .series, title: "Series", symbolName: "books.vertical"),
            RailItem(destination: .collections, title: "Collections", symbolName: "square.stack.3d.up"),
            RailItem(destination: .stats, title: "Stats & Badges", symbolName: "chart.bar"),
        ],
        [
            RailItem(destination: .tracking, title: "Playtime Tracking", symbolName: "timer"),
            RailItem(destination: .nxnative, title: "NXNative Builds", symbolName: "hammer"),
        ],
    ]
}
