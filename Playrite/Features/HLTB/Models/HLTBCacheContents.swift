import Foundation

/// What a cache load found: the estimates it could read, and how many entries it had to skip.
struct HLTBCacheContents: Equatable, Sendable {
    /// Readable estimates by game.
    var estimates: [UUID: HLTBEstimate]
    /// Entries present in the file that couldn't be read.
    var skippedEntries = 0
}
