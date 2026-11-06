import Foundation

/// Persistent cache of HLTB estimates. Live: ``FileHLTBCache``; mock: ``InMemoryHLTBCache``.
protocol HLTBCaching: Sendable {
    /// All cached estimates keyed by game.
    func load() throws -> [UUID: HLTBEstimate]
    /// Replaces the whole cache.
    func save(_ estimates: [UUID: HLTBEstimate]) throws
}
