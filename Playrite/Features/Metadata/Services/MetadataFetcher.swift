import Foundation

/// Live ``MetadataFetching``.
///
/// Games are processed one at a time, so store calls are serialised (the injected HTTP client also spaces them per
/// host). For each game: official sources first — the Steam store, then Nintendo eShop data (titledb, ADR 0038) for
/// Switch ports with no Steam twin — then SteamGridDB only for cover or hero art still missing. Which fields may be
/// written is decided by ``MetadataFillPolicy``; the one exception is ``HeroUpgradeRule``. Every fill and hero swap is
/// written to the audit log.
@MainActor
final class MetadataFetcher: MetadataFetching {
    private let repository: any LibraryRepository
    private let steamStore: any MetadataProviding
    private let nintendo: any MetadataProviding
    private let steamGridDB: any MetadataProviding
    private let downloader: ArtworkDownloader
    private let audit: (any AuditLogging)?
    private let now: () -> Date
    private var attemptedThisSession: Set<UUID> = []

    /// Creates the fetcher.
    init(
        repository: any LibraryRepository,
        steamStore: any MetadataProviding,
        nintendo: any MetadataProviding,
        steamGridDB: any MetadataProviding,
        downloader: ArtworkDownloader,
        audit: (any AuditLogging)? = nil,
        now: @escaping () -> Date = Date.init
    ) {
        self.repository = repository
        self.steamStore = steamStore
        self.nintendo = nintendo
        self.steamGridDB = steamGridDB
        self.downloader = downloader
        self.audit = audit
        self.now = now
    }

    func fetchMissing() async throws -> MetadataFetchSummary {
        try await fillMissing(skippingAttempted: false)
    }

    func fetchMissingInBackground() async throws -> MetadataFetchSummary {
        try await fillMissing(skippingAttempted: true)
    }

    private func fillMissing(skippingAttempted: Bool) async throws -> MetadataFetchSummary {
        var summary = MetadataFetchSummary(finishedAt: now())
        for game in try repository.fetchGames() where !(skippingAttempted && attemptedThisSession.contains(game.id)) {
            attemptedThisSession.insert(game.id)
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
        let steam = steamStore.applies(to: query)
            ? await collect(from: steamStore, query, writable, &update)
            : (outcome: MetadataOutcome.skipped, metadata: nil)
        summary.record(steam.outcome, for: steamStore.source)
        var heroUpgrade = false
        if steam.metadata != nil || !nintendo.applies(to: query) {
            summary.record(.skipped, for: nintendo.source)
        } else {
            let eshop = await collect(from: nintendo, query, writable, &update)
            summary.record(eshop.outcome, for: nintendo.source)
            heroUpgrade = await upgradeHero(of: game, from: eshop.metadata, &update)
        }
        let missingArt = writable.intersection([.cover, .hero]).subtracting(update.fields)
        if missingArt.isEmpty {
            summary.record(.skipped, for: steamGridDB.source)
        } else {
            await summary.record(
                collect(from: steamGridDB, query, missingArt, &update).outcome,
                for: steamGridDB.source
            )
        }
        guard !update.isEmpty else { return }
        MetadataApplier.apply(update, to: game)
        summary.gamesUpdated += 1
        report(update, for: game, heroUpgrade: heroUpgrade)
    }

    /// Official key art replaces a SteamGridDB hero only when ``HeroUpgradeRule`` says it is clearly better.
    private func upgradeHero(
        of game: Game,
        from metadata: FetchedMetadata?,
        _ update: inout MetadataUpdate
    ) async -> Bool {
        guard let metadata, !metadata.heroCandidates.isEmpty, !update.fields.contains(.hero),
              HeroUpgradeRule.isClearlyBetter(
                  currentSource: game.metadataProvenance[.hero],
                  currentPixelWidth: HeroUpgradeRule.pixelWidth(ofImageAt: game.heroImagePath),
                  candidatePixelWidth: TitleDBMetadataMapper.bannerPixelWidth
              ),
              let path = await downloader.firstImage(from: metadata.heroCandidates, gameID: game.id, kind: .hero)
        else { return false }
        update.setArtwork(.hero, paths: [path], source: metadata.source)
        return true
    }

    /// One audit entry per filled field, so every fill is on record.
    private func report(_ update: MetadataUpdate, for game: Game, heroUpgrade: Bool) {
        guard let audit else { return }
        for field in MetadataField.allCases where update.fields.contains(field) {
            let source = update.sources[field]?.displayName ?? "unknown"
            let swapped = field == .hero && heroUpgrade
            try? audit.record(AuditEntry(
                action: swapped ? "metadata.heroUpgrade" : "metadata.fill",
                target: game.title,
                details: swapped
                    ? "Hero replaced: SteamGridDB art → official key art from \(source)"
                    : "\(field.displayName) filled from \(source)"
            ))
        }
    }

    /// Asks one provider and folds what it offers into `update`. `metadata` is set when the provider recognised the
    /// game, even if it had nothing new to add.
    private func collect(
        from provider: any MetadataProviding,
        _ query: MetadataQuery,
        _ allowed: Set<MetadataField>,
        _ update: inout MetadataUpdate
    ) async -> (outcome: MetadataOutcome, metadata: FetchedMetadata?) {
        let lookup: MetadataLookup
        do {
            lookup = try await provider.lookup(query)
        } catch {
            return (.failed, nil)
        }
        guard case let .found(metadata) = lookup else { return (.skipped, nil) }
        let before = update.fields.count
        update.takeText(from: metadata, allowed: allowed)
        await takeArtwork(from: metadata, gameID: query.gameID, allowed: allowed.subtracting(update.fields), &update)
        return (update.fields.count > before ? .filled : .skipped, metadata)
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
