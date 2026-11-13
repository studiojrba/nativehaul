/// The maths behind ``ArtworkPaletteExtractor`` (ADR 0054), separate from image decoding so it is unit-testable.
///
/// - `mid`: the dominant colour — pixels are binned by hue, each weighted by its chroma, and the heaviest bin's mean
///   wins (so a large muddy area loses to a smaller vivid one only when it is far less colourful). Near-grey art
///   falls back to the overall mean.
/// - `deep`: the mean of the darkest quarter, settled toward the evening tone.
/// - `light`, `wash`, `ink`: tints of `mid` toward white and the daylight paper, like the hand-made palettes.
enum PaletteAnalysis {
    /// Hue bins around the colour wheel.
    static let hueBins = 12
    /// Below this chroma a pixel counts as grey and votes for no hue.
    static let greyChroma = 0.08
    /// Share of the pixels, darkest first, that form `deep`.
    static let deepShare = 0.25
    /// How far `deep` settles toward the evening tone.
    static let deepSettle = 0.35
    /// How far `light` moves from `mid` toward white.
    static let lightTint = 0.62
    /// How far `wash` moves from `light` toward the daylight paper.
    static let washTint = 0.5
    /// How far `ink` moves from `light` toward white.
    static let inkTint = 0.8

    private static let degreesPerTurn = 360.0
    private static let sextant = 60.0
    private static let greenOffset = 2.0
    private static let blueOffset = 4.0
    private static let sextants = 6.0

    /// The palette for `pixels` (opaque sRGB), or ``GamePalette/neutral`` when there are none.
    static func palette(from pixels: [RGBA]) -> GamePalette {
        guard !pixels.isEmpty else { return .neutral }
        let mid = dominant(in: pixels)
        let darkCount = max(1, Int((Double(pixels.count) * deepShare).rounded()))
        let darkest = pixels.sorted { $0.luminance < $1.luminance }.prefix(darkCount)
        let deep = mean(Array(darkest)).mixed(with: Palette.evening, by: deepSettle)
        let light = mid.mixed(with: Palette.white, by: lightTint)
        return GamePalette(
            deep: deep,
            mid: mid,
            light: light,
            wash: light.mixed(with: ThemeTokens.light.paper, by: washTint),
            ink: light.mixed(with: Palette.white, by: inkTint)
        )
    }

    /// The chroma-weighted dominant hue's mean colour, or the overall mean for grey art.
    static func dominant(in pixels: [RGBA]) -> RGBA {
        var weights = [Double](repeating: 0, count: hueBins)
        var members = [[RGBA]](repeating: [], count: hueBins)
        for pixel in pixels where pixel.chroma >= greyChroma {
            let bin = min(hueBins - 1, Int(hue(of: pixel) / degreesPerTurn * Double(hueBins)))
            weights[bin] += pixel.chroma
            members[bin].append(pixel)
        }
        guard let best = weights.indices.max(by: { weights[$0] < weights[$1] }), weights[best] > 0 else {
            return mean(pixels)
        }
        return mean(members[best])
    }

    /// Hue in degrees, 0..<360.
    static func hue(of color: RGBA) -> Double {
        let high = max(color.red, color.green, color.blue)
        let chroma = color.chroma
        guard chroma > 0 else { return 0 }
        let raw: Double = switch high {
        case color.red: ((color.green - color.blue) / chroma).truncatingRemainder(dividingBy: sextants)
        case color.green: (color.blue - color.red) / chroma + greenOffset
        default: (color.red - color.green) / chroma + blueOffset
        }
        let degrees = raw * sextant
        return degrees < 0 ? degrees + degreesPerTurn : degrees
    }

    /// The channel-wise mean, rounded to 8 bits.
    static func mean(_ colors: [RGBA]) -> RGBA {
        guard !colors.isEmpty else { return GamePalette.neutral.mid }
        let count = Double(colors.count)
        let sum = colors.reduce((0.0, 0.0, 0.0)) { ($0.0 + $1.red, $0.1 + $1.green, $0.2 + $1.blue) }
        let byte = { (value: Double) in Int((value / count * Double(UInt8.max)).rounded()) }
        return RGBA(red8: byte(sum.0), green8: byte(sum.1), blue8: byte(sum.2))
    }
}
