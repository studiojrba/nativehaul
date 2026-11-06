# ADR 0009 — Guides are link-out only; HLTB is a labelled, locally cached estimate layer

**Status:** Accepted · 2026-11-06

## Context
Players want walkthrough links per game (often per chapter) and completion-time estimates. GameFAQs guide content
belongs to its authors; HowLongToBeat publishes no official public API and its terms disallow scraping.

## Decision
- **Guides**: `GuideLink` stores only a GameFAQs URL, title, author, and chapter links (title + URL within the same
  guide). URLs are validated to GameFAQs hosts over https; title and author are mandatory and every link shows a full
  attribution line. Links open in the user's browser via `URLOpening`. Playrite performs **no network requests** for
  guides: no scraping, caching, or embedding of guide content.
- **HLTB**: `HLTBProviding` is a cache-first data layer (`CachedHLTBService` + `HLTBCaching` file/in-memory caches,
  30-day staleness) with a pluggable `HLTBRemoteSearching`. The shipped remote is `UnavailableHLTBRemoteSource`
  (no official API → no automatic fetching). Figures are entered by the user (with a link-out search on
  howlongtobeat.com) and cached locally.
- Every HLTB figure is rendered with the label **"HLTB estimate"**; it appears as its own row in breakdowns and a
  separate "Backlog Estimate" on the stats page, and is never added to real playtime or used by badges.

## Consequences
- No legal or ToS exposure from guide or HLTB scraping; attribution is always visible.
- HLTB figures require manual entry until an official/licensed source exists — plug it in by implementing
  `HLTBRemoteSearching` without touching UI or cache code.
