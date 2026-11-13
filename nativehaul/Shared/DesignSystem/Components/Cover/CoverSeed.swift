import Foundation

/// A stable hash for drawn covers (FNV-1a over the title's UTF-8), so a game's palette and motif never change between
/// launches (Swift's own `hashValue` is seeded per process).
enum CoverSeed {
    private static let offsetBasis: UInt64 = 0xCBF2_9CE4_8422_2325
    private static let prime: UInt64 = 0x0000_0100_0000_01B3
    /// Mixes in the title's second half so the motif doesn't follow the palette in lockstep.
    private static let motifSalt: UInt64 = 0x9E37_79B9_7F4A_7C15

    /// The hash of `text`.
    static func hash(_ text: String) -> UInt64 {
        text.utf8.reduce(offsetBasis) { ($0 ^ UInt64($1)) &* prime }
    }

    /// A second, independent hash of `text` (for the motif): the title hash, salted, through SplitMix64's finaliser.
    static func motifHash(_ text: String) -> UInt64 {
        var mixed = hash(text) ^ motifSalt
        mixed = (mixed ^ (mixed >> shiftA)) &* multiplierA
        mixed = (mixed ^ (mixed >> shiftB)) &* multiplierB
        return mixed ^ (mixed >> shiftC)
    }

    // SplitMix64's published finaliser constants.
    private static let shiftA: UInt64 = 30
    private static let shiftB: UInt64 = 27
    private static let shiftC: UInt64 = 31
    private static let multiplierA: UInt64 = 0xBF58_476D_1CE4_E5B9
    private static let multiplierB: UInt64 = 0x94D0_49BB_1331_11EB
}
