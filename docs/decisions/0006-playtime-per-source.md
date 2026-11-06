# ADR 0006 — Playtime stored per source, never merged

**Status:** Accepted · 2026-11-06

## Context
Playtime arrives from Steam, the Mac session tracker, the user, and HowLongToBeat (an estimate, not playtime).
Summing them silently double-counts and mixes facts with estimates.

## Decision
Every playtime figure carries a `PlaytimeSource` (`steamSynced`, `macTracked`, `selfReported`, `hltbEstimate`).
Storage, statistics and UI keep figures separated by source. No API returns a merged total; HLTB values are
always labelled "HLTB estimate" and excluded from badges.

## Consequences
- Honest, auditable numbers; stats show per-source breakdowns.
- UI must render several figures instead of one — handled by a reusable `SourceBadge`/breakdown component.
