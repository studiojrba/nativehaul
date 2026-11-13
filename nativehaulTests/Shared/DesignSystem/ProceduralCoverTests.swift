import Foundation
@testable import nativehaul
import Testing

/// Note 14: drawn covers are the default; each game keeps the same palette and motif on every launch.
struct ProceduralCoverTests {
    @Test func aTitleAlwaysGetsTheSameCover() {
        #expect(CoverSeed.hash("Pikmin 4") == CoverSeed.hash("Pikmin 4"))
        #expect(CoverPalette.forTitle("Pikmin 4") == CoverPalette.forTitle("Pikmin 4"))
        #expect(CoverMotif.forTitle("Pikmin 4") == CoverMotif.forTitle("Pikmin 4"))
        // FNV-1a's published value for the empty string: stable across processes, unlike `hashValue`.
        #expect(CoverSeed.hash("") == 0xCBF2_9CE4_8422_2325)
    }

    @Test func differentTitlesSpreadAcrossPalettesAndMotifs() {
        let titles = (1 ... 40).map { "Game number \($0)" }
        #expect(Set(titles.map { CoverPalette.forTitle($0).deep.hex }).count > CoverPalette.bank.count / 2)
        #expect(Set(titles.map(CoverMotif.forTitle)).count > CoverMotif.allCases.count / 2)
    }
}
