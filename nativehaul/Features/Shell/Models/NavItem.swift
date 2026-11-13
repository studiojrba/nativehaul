import Foundation

/// A button in the nav island (spec §3.0): Home, Library, Builds, Settings — in that order.
enum NavItem: CaseIterable, Identifiable, Sendable {
    case home
    case library
    case builds
    case settings

    /// Stable identity.
    var id: AppScreen {
        screen
    }

    /// The screen it opens.
    var screen: AppScreen {
        switch self {
        case .home: .home
        case .library: .library
        case .builds: .builds
        case .settings: .settings
        }
    }

    /// Tooltip and VoiceOver label.
    var title: String {
        switch self {
        case .home: "Home"
        case .library: "Library"
        case .builds: "Builds"
        case .settings: "Settings"
        }
    }

    /// SF Symbol.
    var symbolName: String {
        switch self {
        case .home: "house"
        case .library: "square.grid.2x2"
        case .builds: "hammer"
        case .settings: "slider.horizontal.3"
        }
    }
}
