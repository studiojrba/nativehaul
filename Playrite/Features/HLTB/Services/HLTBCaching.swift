import Foundation

/// Persistent cache of HLTB estimates. Live: ``FileHLTBCache``; mock: ``InMemoryHLTBCache``.
protocol HLTBCaching: Sendable {
    /// All readable estimates keyed by game, with a count of entries that couldn't be read. Throws
    /// ``HLTBError/cacheUnreadable(_:)`` when the file isn't a list of estimates at all.
    func load() throws -> HLTBCacheContents
    /// Replaces the whole cache.
    func save(_ estimates: [UUID: HLTBEstimate]) throws
}
