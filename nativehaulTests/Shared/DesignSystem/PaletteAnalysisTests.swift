import CoreGraphics
import Foundation
import ImageIO
@testable import nativehaul
import Testing
import UniformTypeIdentifiers

/// ADR 0054: a game's palette comes from its artwork.
struct PaletteAnalysisTests {
    private let blue = RGBA(hex: 0x2050D0)
    private let orange = RGBA(hex: 0xF08020)

    @Test func noPixelsGiveTheNeutralPalette() {
        #expect(PaletteAnalysis.palette(from: []) == .neutral)
    }

    @Test func aSolidColourIsItsOwnMid() {
        let palette = PaletteAnalysis.palette(from: Array(repeating: orange, count: 64))
        #expect(palette.mid.hex == orange.hex)
        #expect(palette.deep.luminance < palette.mid.luminance)
        #expect(palette.light.luminance > palette.mid.luminance)
        #expect(palette.wash.luminance > palette.light.luminance)
        #expect(palette.ink.luminance > palette.light.luminance)
    }

    @Test func theDominantHueWins() {
        let pixels = Array(repeating: blue, count: 48) + Array(repeating: orange, count: 16)
        #expect(PaletteAnalysis.palette(from: pixels).mid.hex == blue.hex)
        let flipped = Array(repeating: blue, count: 16) + Array(repeating: orange, count: 48)
        #expect(PaletteAnalysis.palette(from: flipped).mid.hex == orange.hex)
    }

    @Test func greyArtFallsBackToTheMean() {
        let pixels = Array(repeating: RGBA(hex: 0x404040), count: 8) + Array(repeating: RGBA(hex: 0xC0C0C0), count: 8)
        #expect(PaletteAnalysis.palette(from: pixels).mid.hex == 0x808080)
    }

    @Test func huesLandOnTheWheel() {
        #expect(PaletteAnalysis.hue(of: RGBA(hex: 0xFF0000)) == 0)
        #expect(PaletteAnalysis.hue(of: RGBA(hex: 0x00FF00)) == 120)
        #expect(PaletteAnalysis.hue(of: RGBA(hex: 0x0000FF)) == 240)
        #expect(PaletteAnalysis.hue(of: RGBA(hex: 0xFF00FF)) == 300)
    }

    @Test func theExtractorReadsATwoColourImageOffTheMainActor() async throws {
        let url = try Self.writeImage(top: blue, bottom: orange, topShare: 0.75)
        defer { try? FileManager.default.removeItem(at: url) }
        let palette = await ArtworkPaletteExtractor().palette(forImageAt: url)
        let delta = abs(Int(palette.mid.hex >> 16) - Int(blue.hex >> 16))
        #expect(delta <= 2, "mid \(String(palette.mid.hex, radix: 16))")
        #expect(palette.mid.blue > palette.mid.red)
    }

    @Test func theExtractorFallsBackWithoutArt() async {
        #expect(await ArtworkPaletteExtractor().palette(forImageAt: nil) == .neutral)
        let missing = URL(fileURLWithPath: "/missing/cover.png")
        #expect(await ArtworkPaletteExtractor().palette(forImageAt: missing) == .neutral)
    }

    @Test func theMockReturnsItsPalettes() async {
        let url = URL(fileURLWithPath: "/covers/a.png")
        let mock = MockGamePaletteExtractor(palettes: [url.path(percentEncoded: false): GamePalette.neutral])
        #expect(await mock.palette(forImageAt: url) == .neutral)
    }

    /// A 64×96 PNG: `top` over the top share, `bottom` below.
    private static func writeImage(top: RGBA, bottom: RGBA, topShare: CGFloat) throws -> URL {
        let width = 64
        let height = 96
        let space = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let context = try #require(CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        let split = CGFloat(height) * (1 - topShare)
        context.setFillColor(bottom.nsColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: split))
        context.setFillColor(top.nsColor.cgColor)
        context.fill(CGRect(x: 0, y: split, width: CGFloat(width), height: CGFloat(height) - split))
        let image = try #require(context.makeImage())
        let url = FileManager.default.temporaryDirectory.appending(path: "palette-\(UUID().uuidString).png")
        let destination = try #require(CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ))
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
        return url
    }
}
