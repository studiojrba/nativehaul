import Foundation

/// Live ``MetadataFetching``.
///
/// Games are processed one at a time, so store calls are serialised (the injected HTTP client also spaces them per
/// host). For each game: official sources first — the Steam store, then the Nintendo eShop for Switch games with no
/// Steam twin — then SteamGridDB only for cover or hero art still missing. Which fields may be written is decided by
/// ``MetadataFillPolicy``.
@MainActor
final class MetadataFetcher: MetadataFetching {
    private let repository: any LibraryRepository
    private let steamStore: any MetadataProviding
    private let nintendo: any MetadataProviding
    private let steamGridDB: any MetadataProviding
    private let downloader: ArtworkDownloader
    private let now: () -> Date

    /// Creates the fetcher.
    init(
        repository: any LibraryRepository,
        steamStore: any MetadataProviding,
        nintendo: any MetadataProviding,
        steamGridDB: any MetadataProviding,
        downloader: ArtworkDownloader,
        now: @escaping () -> Date = Date.init
    ) {
        self.repository = repository
        self.steamStore = steamStore
        self.nintendo = nintendo
        self.steamGridDB = steamGridDB
        self.downloader = downloader
        self.now = now
    }

    func fetchMissing() async throws -> MetadataFetchSummary {
        var summary = MetadataFetchSummary(finishedAt: now())
        for game in try repository.fetchGames() {
            await process(game, mode: .fillMissing, summary: &summary)
            try repository.save()
        }
        summary.finishedAt = now()
        return summary
    }

    func refresh(_ game: Game) async throws -> MetadataFetchSummary {
        var summary = MetadataFetchSummary(finishedAt: now())
        await process(game, mode: .refresh, summary: &summary)
        try repository.save()
        summary.finishedAt = now()
        return summary
    }

    private func process(_ game: Game, mode: MetadataFetchMode, summary: inout MetadataFetchSummary) async {
        let writable = MetadataFillPolicy.writableFields(for: game, mode: mode)
        guard !writable.isEmpty else {
            summary.gamesComplete += 1
            return
        }
        let query = game.metadataQuery
        var update = MetadataUpdate()
        let steam = await collect(from: steamStore, query, writable, &update)
        summary.record(steam.outcome, for: .steamStore)
        if steam.matched || !nintendo.applies(to: query) {
            summary.record(.skipped, for: .nintendoStore)
        } else {
            await summary.record(collect(from: nintendo, query, writable, &update).outcome, for: .nintendoStore)
        }
        let missingArt = writable.intersection([.cover, .hero]).subtracting(update.fields)
        if missingArt.isEmpty {
            summary.record(.skipped, for: .steamGridDB)
        } else {
            await summary.record(collect(from: steamGridDB, query, missingArt, &update).outcome, for: .steamGridDB)
        }
        guard !update.isEmpty else { return }
        MetadataApplier.apply(update, to: game)
        summary.gamesUpdated += 1
    }

    /// Asks one provider and folds what it offers into `update`. `matched` is true when the provider recognised the
    /// game, even if it had nothing new to add.
    private func collect(
        from provider: any MetadataProviding,
        _ query: MetadataQuery,
        _ allowed: Set<MetadataField>,
        _ update: inout MetadataUpdate
    ) async -> (outcome: MetadataOutcome, matched: Bool) {
        let lookup: MetadataLookup
        do {
            lookup = try await provider.lookup(query)
        } catch {
            return (.failed, false)
        }
        guard case let .found(metadata) = lookup else { return (.skipped, false) }
        let before = update.fields.count
        update.takeText(from: metadata, allowed: allowed)
        await takeArtwork(from: metadata, gameID: query.gameID, allowed: allowed.subtracting(update.fields), &update)
        return (update.fields.count > before ? .filled : .skipped, true)
    }

    private func takeArtwork(
        from metadata: FetchedMetadata,
        gameID: UUID,
        allowed: Set<MetadataField>,
        _ update: inout MetadataUpdate
    ) async {
        let singles = [(MetadataField.cover, metadata.coverCandidates), (.hero, metadata.heroCandidates)]
        for (field, candidates) in singles where allowed.contains(field) && !candidates.isEmpty {
            guard let kind = field.artworkKind,
                  let path = await downloader.firstImage(from: candidates, gameID: gameID, kind: kind)
            else { continue }
            update.setArtwork(field, paths: [path], source: metadata.source)
        }
        if allowed.contains(.carousel), !metadata.carouselImages.isEmpty {
            let paths = await downloader.carousel(from: metadata.carouselImages, gameID: gameID)
            update.setArtwork(.carousel, paths: paths, source: metadata.source)
        }
    }
}
