import Foundation

extension CaseArtwork {
    /// A stand-in case for previews: no art (the warm placeholder shows), a short description and a footer.
    static let preview = CaseArtwork(
        coverPath: nil,
        title: "Lantern Coast",
        shortTitle: "Lantern Coast",
        label: "Game Card",
        screenshots: [],
        summary: "A small boat, a long coastline and a lighthouse for every evening.",
        footer: "Harbour Lights · 2024",
        barcode: CaseBarcode.bars(for: "0100ABCD00010000"),
        colors: .red,
        panel: GamePalette.neutral.light.mixed(with: Palette.white, by: CaseColors.Print.panelWhiteMix)
    )
}
