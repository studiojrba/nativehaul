import Foundation

/// Derives a ``GamePalette`` from a game's cover art (ADR 0054). Protocol-first (ADR 0002): the live implementation
/// reads the image off the main actor; previews and tests use ``MockGamePaletteExtractor``.
protocol GamePaletteExtracting: Sendable {
    /// The palette for the image at `url`, or ``GamePalette/neutral`` when there is no readable image.
    func palette(forImageAt url: URL?) async -> GamePalette
}
