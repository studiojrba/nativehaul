import Foundation

/// Where a guide step takes the user (ADR 0040): the real place the step describes.
enum GuideDestination: Equatable, Sendable {
    /// Home.
    case home
    /// The library grid.
    case library
    /// A game's detail page.
    case gamePage
    /// The Builds page.
    case builds
    /// Settings, on the Steam tab.
    case steamSettings
}
