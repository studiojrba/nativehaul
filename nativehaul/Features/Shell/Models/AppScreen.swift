import Foundation

/// The desktop screens (spec §3.0).
enum AppScreen: String, Hashable, Sendable {
    /// Home: hero, Continue playing, the whole shelf.
    case home
    /// Library: every game, sorted.
    case library
    /// One game's details (opened from another screen; Back returns there).
    case detail
    /// The build pipeline.
    case builds
    /// Settings.
    case settings

    /// The nav island button that lights for this screen (Detail counts as Library).
    var islandScreen: AppScreen {
        self == .detail ? .library : self
    }
}
