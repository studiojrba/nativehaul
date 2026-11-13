import Foundation

/// Everything printed on the case (spec §3.3), from the game's real data: the cover on the front, the short title on
/// the spine and back, up to four screenshots, the description and the footer on the back, and the barcode.
struct CaseArtwork: Equatable, Sendable {
    /// The cover art path.
    let coverPath: String?
    /// The full title (placeholder art and VoiceOver).
    let title: String
    /// The short title (spine and back heading).
    let shortTitle: String
    /// The label on the frame's band: "Game Card" for Switch ports, else the system.
    let label: String
    /// Back screenshots (at most four).
    let screenshots: [String]
    /// The back's description, if any.
    let summary: String?
    /// The back's footer ("{studio} · {year}"), if known.
    let footer: String?
    /// Barcode bar widths.
    let barcode: [Int]
    /// The case's physical colours.
    let colors: CaseColors
    /// The back panel's colour: the palette's light tone mixed toward white.
    let panel: RGBA

    /// The artwork for `game` with `palette`.
    @MainActor
    static func make(for game: Game, palette: GamePalette) -> CaseArtwork {
        let summary = game.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        return CaseArtwork(
            coverPath: game.coverImagePath,
            title: game.title,
            shortTitle: ShortTitle.make(from: game.title),
            label: label(for: game),
            screenshots: Array(DetailFacts.screenshots(for: game).prefix(ShellLayout.GameCase.backShotCount)),
            summary: summary.isEmpty ? nil : summary,
            footer: DetailFacts.caseFooter(for: game),
            barcode: CaseBarcode.bars(for: DetailFacts.barcodeSource(for: game)),
            colors: DetailFacts.caseColors(for: game),
            panel: palette.light.mixed(with: Palette.white, by: CaseColors.Print.panelWhiteMix)
        )
    }

    /// "Game Card" on Switch cases; the system or "Mac" on the others.
    @MainActor
    static func label(for game: Game) -> String {
        switch game.platform {
        case .switchPort: "Game Card"
        case .emulated: game.emulatedSystem?.displayName ?? "Game"
        case .macNative: "Mac"
        case .other: "Game"
        }
    }
}
