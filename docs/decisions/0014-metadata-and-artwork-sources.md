# ADR 0014 — Metadata and artwork: official sources first, cached on disk

**Status:** Accepted · 2026-11-06

## Context
J.R wants every game to have a portrait cover, a wide hero, carousel slides, a description, and the developer,
genre, tag and release-date fields that branch 11 added. His standing rule is official art only: no box or case
photos, no rating-badge renders, no fan art and no watermarks. Art he chose himself must never be overwritten.

## Decision
- **Sources, in priority order:**
  1. **Steam store `appdetails`** (public, no Web API key). It is used for games with a Steam app ID, or for a
     single exact title match from the store's own search. It supplies the short description, developer, genres,
     categories (stored as tags) and release date. Art comes from Steam's official library assets: the 600×900
     portrait capsule, the library hero, then the store background and header. The carousel takes up to 8
     screenshots and 2 trailer thumbnails.
  2. **Nintendo eShop**, for Switch games with no Steam twin. Only Nintendo's wide key art is used, as the hero.
     Portrait packshots are excluded because they are box renders with rating badges. **No live source is
     connected** (see Consequences): the provider, mapper and matching rules are built and tested behind
     `NintendoStoreSearching`, and the live app uses `UnavailableNintendoStoreSearch`.
  3. **SteamGridDB**, as the fallback for portrait grids and heroes only. It needs J.R's key, stored in the
     Keychain from Settings → Artwork. The key is sent only in the `Authorization` header. The request filters
     out NSFW, humour and epilepsy-risk art and keeps static images only. Blurred styles are dropped
     client-side. SteamGridDB is asked only when no official source supplied a cover or hero.
- **Matching:** app ID first, then `TitleNormalizer` (the same key the deduplicator uses). The title must match
  exactly after normalising. If nothing matches, or two different items match, the field stays blank.
- **Which fields a pass may write** is decided in one place, `MetadataFillPolicy`:
  - Fields marked as set by the user are never written.
  - **Fetch Missing Metadata** fills only empty fields.
  - **Refresh Metadata** (per game, in Manage) may also replace fetched or imported text, and art that an earlier
    pass downloaded.
  - Art with no recorded source predates this branch or was chosen by hand, so it is treated as manual and kept.
- **Provenance:** recorded per field on `Game.metadataSourcesRaw` as `field=source` entries. It is exported and
  imported with the library, and carried across merges. Choose Cover… and Choose Hero Image… mark the field as
  set by the user.
- **Cache:** each image is downloaded once into `~/Library/Application Support/Playrite/Artwork/<game-id>/`
  (`cover.*`, `hero.*`, `carousel-NN.*`), and views render from disk. A candidate is cached only if its bytes are
  a real JPEG, PNG, WebP or GIF, so an error page never becomes art. Nothing is hotlinked or bundled.
- **Rate limiting:** games are processed one at a time. A `ThrottledHTTPClient` spaces requests per host:
  1.5 s for the Steam store, 0.5 s for SteamGridDB and 0.25 s for image downloads.
- **Summary:** each pass reports games updated, games already complete, and filled, skipped and failed counts
  per source, like the other sync summaries.
- **Playtime, status, sessions and tracking** are never touched.

## Consequences
- **Nintendo is a seam, not a working source.** Nintendo has no public metadata API. nintendo.com's store search
  runs on an internal, embedded search key, and using it from Playrite would mean borrowing that website's
  private access. That is outside the project's no-scraping rule, so it was not done. Switch ports without a Steam
  twin get their art from SteamGridDB for now. Connecting a real Nintendo source means one new
  `NintendoStoreSearching` implementation, once J.R picks an approved one.
- **SteamGridDB art is community-uploaded.** The filters remove the worst of it, but they cannot prove a grid is
  official or watermark-free. That is why it is used only as a fallback, why its source is shown in Manage, and
  why Choose Cover… always wins.
- **Untested against the live services.** The Steam library-asset URLs and `appdetails` response shapes match
  Steam's current public CDN and store, but they are covered only by recorded fixtures. Older apps without a
  600×900 capsule fall back to SteamGridDB.
- **Leftover files:** if a refresh produces fewer carousel slides, or changes an image's format, the old cache
  files stay on disk but nothing references them.
