import Foundation

/// ``GamePaletteExtracting`` for previews and tests: fixed palettes per image path, ``GamePalette/neutral`` otherwise.
struct MockGamePaletteExtractor: GamePaletteExtracting {
    /// Palettes by image path.
    let palettes: [String: GamePalette]

    /// Creates the mock.
    init(palettes: [String: GamePalette] = [:]) {
        self.palettes = palettes
    }

    func palette(forImageAt url: URL?) async -> GamePalette {
        url.flatMap { palettes[$0.path(percentEncoded: false)] } ?? .neutral
    }
}
