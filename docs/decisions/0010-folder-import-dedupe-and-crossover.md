# ADR 0010 — Game folder import: strict dedupe, title linking, CrossOver as platform "other"

**Status:** Accepted · 2026-11-06

## Context
The owner keeps games in several folders (`~/Switch/Games`, Mac games, CrossOver launchers) and is importing a
logbook library whose Switch entries have no bundle paths yet. A folder scan must connect those entries to the real
builds without ever creating duplicates, and must be safe to run repeatedly.

## Decision
- **One scanner.** `AppBundleScanner` (from playtime tracking) gains `AppBundleScanOptions`: the tracking dashboard
  keeps its shallow scan, folder import walks 4 levels. Bundles are never descended into; hidden items, the Trash,
  symlinked folders and Playrite itself are skipped. Titles come from `CFBundleDisplayName` → `CFBundleName` → filename.
- **Strict dedupe** (`GameFolderImporter`): a bundle path already on any game is skipped (re-scans are idempotent);
  a bundle whose normalised title (`TitleNormalizer`: case/diacritic/punctuation-insensitive) matches a game with no
  bundle path is **linked** to it; only otherwise is a new backlog game created.
- **Platform:** inside the Switch games folder or beside a hidden port library folder (`.nx2apple-library`,
  `.nxnative-lib`) → `switchPort`; CrossOver launchers → `other`; everything else → `macNative`.
- **CrossOver:** bottles are the subfolders of `~/Library/Application Support/CrossOver/Bottles`. Launcher apps in
  `~/Applications/CrossOver` import like bundles (platform `other`). Top-level `Program Files` folders with a plausible
  game `.exe` import as platform `other` with no bundle path and summary "CrossOver bottle: <name>", filtered by an
  explicit, tested `CrossOverSkipList`. A launcher whose name matches an install folder wins; installs are deduped by
  normalised title against the whole library.
- Discovery runs off the main actor and is read-only; only the library is modified.

## Consequences
- Scans are safe to repeat and never duplicate a logbook entry that has a matching title.
- Title linking is name-based: two different games with the same normalised title would link to the first match.
- Bottle installs have no stable on-disk identity in the library (no bundle path), so their dedupe is title-based.
- Steam games inside a CrossOver Steam bottle are intentionally not imported (the `Steam` folder is skip-listed);
  the Steam provider covers them.
