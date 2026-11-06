import Foundation

/// Live ``LibraryDeduplicating``.
///
/// Games whose titles normalise to the same key (``TitleNormalizer``) and do not point at different bundles or
/// Steam apps are one game. The richest entry survives (ties: earliest added), absorbs the others via
/// ``GameMerger``, takes over their series entries, collections and HLTB estimate, and the others are deleted.
@MainActor
final class LibraryDeduplicator: LibraryDeduplicating {
    private let repository: any LibraryRepository
    private let hltb: (any HLTBProviding)?

    /// Creates the deduplicator. `hltb` lets a duplicate's cached estimate move to the survivor.
    init(repository: any LibraryRepository, hltb: (any HLTBProviding)? = nil) {
        self.repository = repository
        self.hltb = hltb
    }

    func findDuplicates() throws -> [DuplicateGroup] {
        try plan().map { survivor, duplicates in
            DuplicateGroup(
                survivorID: survivor.id,
                title: survivor.title,
                duplicateIDs: duplicates.map(\.id),
                gains: gains(for: survivor, from: duplicates)
            )
        }
    }

    @discardableResult
    func mergeAll() throws -> Int {
        let groups = try plan()
        guard !groups.isEmpty else { return 0 }
        let entries = try repository.fetchSeries().flatMap(\.entries)
        let collections = try repository.fetchCollections()
        var deleted = 0
        for (survivor, duplicates) in groups {
            for duplicate in duplicates {
                GameMerger.merge(duplicate, into: survivor)
                for entry in entries where entry.game?.id == duplicate.id {
                    entry.game = survivor
                }
                for collection in collections where collection.parentGame?.id == duplicate.id {
                    collection.parentGame = survivor
                }
                moveEstimate(from: duplicate, to: survivor)
                repository.delete(duplicate)
                deleted += 1
            }
        }
        try repository.save()
        return deleted
    }

    private func plan() throws -> [(Game, [Game])] {
        let games = try repository.fetchGames()
        let byKey = Dictionary(grouping: games) { TitleNormalizer.key(for: $0.title) }
        return byKey
            .filter { !$0.key.isEmpty && $0.value.count > 1 }
            .values
            .compactMap(group(of:))
            .sorted { $0.0.title.localizedStandardCompare($1.0.title) == .orderedAscending }
    }

    private func group(of candidates: [Game]) -> (Game, [Game])? {
        let ranked = candidates.sorted { lhs, rhs in
            let left = GameMerger.richness(of: lhs)
            let right = GameMerger.richness(of: rhs)
            return left == right ? lhs.addedAt < rhs.addedAt : left > right
        }
        guard let survivor = ranked.first else { return nil }
        // Compatibility is checked against everything already accepted, so two different builds never collapse.
        var accepted = [survivor]
        for candidate in ranked.dropFirst() where accepted.allSatisfy({ GameMerger.areCompatible($0, candidate) }) {
            accepted.append(candidate)
        }
        let duplicates = Array(accepted.dropFirst())
        return duplicates.isEmpty ? nil : (survivor, duplicates)
    }

    private func gains(for survivor: Game, from duplicates: [Game]) -> [String] {
        var gains: [String] = []
        if survivor.appBundlePath == nil, duplicates.contains(where: { $0.appBundlePath != nil }) {
            gains.append("tracked app")
        }
        if survivor.steamAppID == nil, duplicates.contains(where: { $0.steamAppID != nil }) {
            gains.append("Steam app")
        }
        let sessions = duplicates.reduce(0) { $0 + $1.sessions.count }
        if sessions > 0 {
            gains.append(sessions == 1 ? "1 session" : "\(sessions) sessions")
        }
        return gains
    }

    private func moveEstimate(from duplicate: Game, to survivor: Game) {
        // A failed cache write leaves the estimate on the deleted id; it is harmless and re-enterable.
        try? hltb?.reassign(from: duplicate.id, to: survivor.id)
    }
}
