# Playrite — Progress Log

Living status log. Each branch appends its section. Legend: ✅ built & compiles · 🧪 unit-tested · 🟡 stubbed · ⛔ blocked.

## Session decisions (overnight build, 2026-11-06)
- **Empty upstream repo**: `origin/main` had no commits. Since nothing may be committed to `main`, feature
  branches are **stacked** — each branches from the previous feature branch's tip. Merge in order 0 → 7.
- **Tooling**: installed `xcodegen`, `swiftformat`, `swiftlint` via Homebrew. Project generated from `project.yml`;
  `Playrite.xcodeproj` is git-ignored. Run `./scripts/bootstrap.sh` then open `Playrite.xcodeproj`.
- **Toolchain observed**: Xcode 27.2, Swift 6.4.2, macOS 26.6 host; deployment target macOS 15.0, arm64 only.
- **Targets**: single app target `Playrite` with strict feature folders (ADR 0005) + `PlayriteTests` (Swift Testing, app-hosted).
- **Push blocked**: `gh` active account `jr-resilia` gets 403 on `studiojrba/Playrite`; see `BLOCKED.md`. All branches are committed locally and must be pushed in the morning (one-liner in BLOCKED.md). **Resolved 2026-11-06** — see "Push & repo rename".
- **Standards addendum** applied from foundation: README, ADRs in `docs/decisions/`, Conventional Commits, mocks + previews, CI planned post-V1.
- **Not sandboxed** (needs `~/Switch/Games` observation, external engine launch, Trash moves). Ad-hoc signed locally.
- **UI**: owner will supply Figma designs later → all views token-driven (`DesignTokens`, `Theme`) and compositional.
  A SwiftLint custom rule blocks numeric literals in `.padding/.frame/.cornerRadius/.spacing` outside DesignSystem.
- Git author for this session: `studiojrba <jr@studiojrba.com>` (repo-local config).

## 0 · feature/project-foundation
- ✅ `CLAUDE.md` project rules, `README.md` quickstart + map, `docs/PLAN.md` roadmap (+ CI next step), ADRs 0001–0006.
- ✅ `project.yml` (XcodeGen), `.swiftformat`, `.swiftlint.yml`, `.gitignore` (blocks keys/game files).
- ✅ `scripts/bootstrap.sh`, `scripts/lint.sh`, `scripts/build.sh` (xcodebuild build + test).
- ✅ `Shared/DesignSystem/{DesignTokens,Theme}`, `App/` entry + placeholder root view with preview. 🧪 1 smoke test.
- ⛔ Not pushed (see BLOCKED.md).
- Build: `** BUILD SUCCEEDED **`, `** TEST SUCCEEDED **`. Lint: clean.

## 1 · feature/library-core
- ✅ SwiftData models (`Features/Library/Models`): `Game`, `PlaySession`, `Series`, `SeriesEntry`, `GameCollection`
  (named to avoid clashing with Swift's `Collection`), `SubGame`; enums `GameStatus`, `GamePlatform`,
  `PlaytimeSource`, `SeriesOrderBasis`; `PlaytimeBreakdown` (per source, no merged total).
- ✅ `Shared/Persistence`: `PlayriteSchema`, `ModelContainerFactory` (on-disk / in-memory).
- ✅ Services: `LibraryRepository` (+ `SwiftDataLibraryRepository`, `MockLibraryRepository` seeded with fictional
  `SampleLibrary`), `LibraryTransferring` (+ `LibraryTransferService`, `MockLibraryTransferService`).
- ✅ JSON import/export: versioned `LibraryArchive` (format v1) with records for every model; import skips
  existing IDs (never overwrites) and rejects newer formats.
- ✅ UI: `NavigationSplitView` sidebar (All / Playing / Backlog / Completed with counts), adaptive cover grid,
  search, context menu (status, remove), Add Game sheet, game detail (cover picker, status, self-reported hours,
  playtime per source, sessions), Import/Export via toolbar menu. All views token-driven with previews.
- ✅ Shared components: `CoverArtView`, `CoverCard`, `TagLabel`, `SectionHeader`, `LabeledValueRow`.
- 🧪 22 tests (filter, breakdown, status transitions, archive round-trip/skip/version, view models).
- Build ✅ · Tests ✅ · Lint ✅ · App launches ✅. ⛔ Not pushed (BLOCKED.md).
- Note: SwiftData objects should be saved before deletion; the mock saves after seeding.

## 2 · feature/steam-provider
- ✅ `Shared/Networking`: `HTTPClient` protocol, `URLSessionHTTPClient` (never logs URLs), `MockHTTPClient` (actor).
- ✅ `Shared/Utilities`: `SecretStore` protocol, `KeychainSecretStore` (live), `InMemorySecretStore` (mock), `SecretKey`.
- ✅ `Features/Steam`: `SteamClientProtocol` with `SteamWebAPIClient` implementing **GetOwnedGames**,
  **GetPlayerAchievements**, **GetRecentlyPlayedGames**; `MockSteamClient`; validated `SteamID`; typed `SteamError`
  (invalid key, private profile, no stats, HTTP, decoding).
- ✅ `SteamAccountStore`: key **only** in Keychain; SteamID64 in UserDefaults. `SteamSyncService` merges owned games by
  app ID, writing only the `steamSynced` figure (other sources untouched); achievements stored as unlocked/total.
- ✅ Graceful no-key mode: no network calls, empty state with Settings link, achievements section explains what to do.
- ✅ UI: Settings window (Steam tab), sidebar "Providers → Steam" dashboard (sync + recently played), achievements
  section on Steam game detail. ADR 0007.
- 🧪 47 tests total (+25: SteamID, endpoints, client decoding/errors, merger, account store, sync, settings VM).
- 🟡 Real-Keychain wrapper and live Steam calls are not exercised by automated tests (no key available overnight).
- Build ✅ · Tests ✅ · Lint ✅. ⛔ Not pushed (BLOCKED.md).

## 3 · feature/playtime-tracking
- ✅ `RunningApplicationObserving` with live `WorkspaceRunningApplicationObserver` (NSWorkspace didLaunch/didTerminate
  notifications → Sendable `RunningAppEvent` AsyncStream) and `MockRunningApplicationObserver`.
- ✅ `SessionTracker` pure state machine (per-PID, normalised bundle paths, minimum session length, finish-all on stop).
- ✅ `PlaytimeWatcher` (live) / `MockPlaytimeWatcher`: picks up already-running tracked apps (uses launch date),
  writes `PlaySession(source: .macTracked)`, updates `lastPlayedAt`, finalises sessions on stop / app quit.
- ✅ `AppBundleScanner` scans `~/Switch/Games` (top level + one subfolder level, read-only). `TrackedAppMatcher` links
  apps to same-titled untracked games or creates new games (Switch port inside the folder, Mac otherwise).
- ✅ Self-reported sessions ("Log Session…") stored with `.selfReported`. Sources stay separate in every view.
- ✅ UI: sidebar "Playtime Tracking" (toggle, playing now with live timer, tracked apps, discovered apps), detail
  "Tracking" section, Settings → Tracking (enable, folder, minimum session).
- 🧪 63 tests total (+16).
- 🟡 Live NSWorkspace observer verified only by build + app launch; not driven by automated tests.
- Build ✅ · Tests ✅ · Lint ✅ · App launches ✅. ⛔ Not pushed (BLOCKED.md).

## 4 · feature/series-collections
- ✅ `UpNextEngine`: full remaining series in true recommended order (by `position`), completed entries dropped,
  part labels passed through verbatim (never renumbered); unlinked entries shown as "Not in library".
- ✅ Series: name, `SeriesOrderBasis` (release / chronological) + notes on why; reorder rewrites positions only.
- ✅ Collections (`GameCollection`): ordered `SubGame`s each with its own status, optional parent library game.
- ✅ UI: sidebar "Organize → Series / Collections"; series list with per-series Up Next strip; series detail (basis,
  notes, Up Next, drag-to-reorder, add/remove entries with part labels); collection detail (status per sub-game,
  reorder, add/remove); game detail shows "Up Next in <Series>" for series it belongs to (directly or via collection).
- ✅ `NameEntrySheet` moved to `Shared/DesignSystem/Components` (used by two features).
- 🧪 79 tests total (+16).
- Build ✅ · Tests ✅ · Lint ✅. ⛔ Not pushed (BLOCKED.md).

## 5 · feature/stats-badges
- ✅ `LibrarySnapshot` / `GameSnapshot` / `SessionSnapshot`: plain-value copies of real data (pure, testable).
  `LibrarySnapshotProviding` with `RepositorySnapshotProvider` (live) and `MockSnapshotProvider`.
- ✅ `StatsCalculator`: games per status/platform, real hours **per source** (no cross-source total, HLTB never
  included), completion % = completed ÷ all games (abandoned stay in the denominator — documented choice).
- ✅ `BadgeEngine` + `BadgeCatalog` (9 badges): First Credits, Credits Collector (10), Marathon (≥4h real session),
  Centurion (≥100h in a *single* real source — split sources do not combine), Saga Complete, Box Set,
  Native Explorer (MacTracked on a Switch port), Seven-Day Streak, Perfectionist (all Steam achievements).
  Each earned badge carries evidence; estimates are excluded everywhere.
- ✅ UI: sidebar "Stats & Badges" — stat tiles, hours by source, badge grid with progress. `StatTile` in shared components.
- 🧪 92 tests total (+13).
- Build ✅ · Tests ✅ · Lint ✅. ⛔ Not pushed (BLOCKED.md).

## 6 · feature/nxnative-module
- ✅ **Optional & unbundled**: off by default; user chooses their own engine. Preflight refuses an engine inside
  Playrite.app; a test asserts the app bundle has no engine/key/title files. Disclaimer shown in Settings and UI.
- ✅ `FileOperating` (live `LocalFileOperations`, mock `InMemoryFileOperations`) has **no delete / empty-Trash API**;
  a policy test scans all sources for `removeItem(`, `emptyTrash`, `rm -rf`, `unlink(`.
- ✅ Preflight (`PreflightRunner`): engine present/executable, engine external, title ID (non-retail → warning),
  **refuse 32-bit** (and unknown), staged-file inventory (names/sizes only), free disk space (source × multiplier),
  output folder.
- ✅ Build queue (`NXNativeViewModel`): sequential processing, per-job work folder, `ProcessBuildEngineRunner` streams
  stdout/stderr line by line (`LineSplitter`), cancel terminates the engine, re-queue.
- ✅ Post-build cleanup (`CleanupPlanner` → preview → `CleanupExecutor`): keep the `.app` renamed to the real title
  (never overwrites: "Title (2).app"), keep the hidden library folder, move leftovers + emptied work folder to the
  **Trash (never emptied)**, leave ambiguous items for review; every action audited. Finished apps are added to the
  library and tracked (`BuiltAppRegistrar`).
- ✅ Troubleshooting KB (bundled JSON) seeded with **"Profile check fails on a non-retail title ID"**: back up script
  (SHA-256 verified) → patch (single literal match, refused if backup missing/corrupt or script changed) → rebuild →
  restore byte-for-byte (in place, permissions kept) → verify. Steps previewable, ordered, reversible ("Revert Patch"),
  audit-logged to `~/Library/Application Support/Playrite/Audit/audit.jsonl`. Log signatures auto-suggest the case.
  Human doc: `docs/troubleshooting/profile-check-non-retail-title-id.md`. ADR 0008.
- ✅ UI: sidebar "Tools → NXNative Builds" (queue, job detail with preflight, cleanup preview, log console, known-issue
  suggestions, knowledge base), troubleshooting sheet with patch editor, step previews and audit log; Settings → NXNative.
- 🧪 123 tests total (+31).
- 🟡 The real engine CLI is unknown: arguments are a template and title metadata is entered manually (no inspection).
  `ProcessBuildEngineRunner` is not exercised against a real engine (none available); the suggested patch text is a
  template the user must adapt to their engine script.
- Build ✅ · Tests ✅ · Lint ✅. ⛔ Not pushed (BLOCKED.md).

## 7 · feature/guides-hltb
- ✅ Guides (`Features/Guides`): `GuideLink` SwiftData model (title, author, URL, chapter links, current chapter) on
  each game; `GuideLinkValidator` allows only https GameFAQs hosts and chapter links inside the same guide;
  mandatory title + author with a full attribution line on every link; `URLOpening` (live `WorkspaceURLOpener`,
  mock `RecordingURLOpener`) opens the browser. **No network calls, no scraping, no embedding.**
  Chapter-aware "Continue: <chapter>" button. Guides included in JSON export/import (optional field — older archives
  still import).
- ✅ HLTB (`Features/HLTB`): `HLTBProviding` → `CachedHLTBService` (cache-first, 30-day staleness, stale fallback),
  `FileHLTBCache` (Application Support JSON) / `InMemoryHLTBCache`, pluggable `HLTBRemoteSearching` with the default
  `UnavailableHLTBRemoteSource` (HLTB has no official API; Playrite doesn't scrape). Manual entry sheet and
  "Look Up on HowLongToBeat" link-out. **Every figure is labelled "HLTB estimate".**
- ✅ Integration: game detail shows HLTB as its own labelled breakdown row (never merged); stats page shows a separate
  "Backlog Estimate (HLTB estimate)"; badges unaffected. ADR 0009.
- 🧪 142 tests total (+19).
- 🟡 Automatic HLTB lookup intentionally not implemented (no official API) — interface ready for a licensed source.
- Build ✅ · Tests ✅ · Lint ✅ · App launches ✅. ⛔ Not pushed (BLOCKED.md).

---

# Final summary (end of overnight session, 2026-11-06)

## 8 · feature/folder-import
Branched from the tip of `feature/guides-hltb`. **Committed locally only** — pushes are still blocked (`BLOCKED.md`).

**Built**
- **Game Folders** settings tab (`Features/FolderImport`): add folders with the system folder picker
  (SwiftUI `fileImporter`, which presents `NSOpenPanel`), remove them, list persisted in `UserDefaults`
  (`UserDefaultsGameFolderStore`). "Scan Game Folders" runs from that tab and from the toolbar's Library menu
  (which also has "Configure Game Folders…"). Scans from Settings refresh the main window via `LibraryChangeNotification`.
- **Scanner reuse:** `AppBundleScanner` now takes `AppBundleScanOptions` (tracking keeps its 2-level scan; folder
  import uses 4 levels). Never descends into a bundle; skips hidden items, `.Trash`/`.Trashes`, symlinked folders,
  `Playrite.app` and Playrite's own bundle path. Reads `CFBundleDisplayName` → `CFBundleName` → filename.
  `TrackedAppMatcher` now matches on `TitleNormalizer` keys (case/diacritics/punctuation-insensitive).
- **Import rules** (`GameFolderImporter`): bundle path already on a game → skipped; normalised title matches a game
  with no bundle path → linked (status and platform untouched); else a new backlog game. Platform: Switch games
  folder or a sibling `.nx2apple-library` / `.nxnative-lib` folder → `switchPort`; CrossOver launcher → `other`;
  else `macNative`. The watcher is refreshed afterwards so linked games are tracked immediately.
- **CrossOver:** bottles under `~/Library/Application Support/CrossOver/Bottles`; launcher apps in
  `~/Applications/CrossOver` (platform `other`, bundle path set); `drive_c/Program Files` and `Program Files (x86)`
  top-level folders with a plausible `.exe` (searched 3 levels deep) → platform `other`, no bundle path, summary
  "CrossOver bottle: <name>". Explicit `CrossOverSkipList` (Windows/Wine components, runtimes, store launchers,
  redistributables, setup/uninstall/crash helpers). Launcher wins over a same-named install.
- **Summary:** found / added / linked / skipped, plus CrossOver bottles found / CrossOver games added, plus any
  unreadable folders. Shown in Settings and as an alert in the main window.
- ADR 0010. Also fixed `scripts/lint.sh --check` (the installed SwiftFormat 0.64 needs paths before `--lint`).

**Tests** — scanner max depth, no descent into bundles, Trash/hidden/Playrite skips, Info.plist titles and the
port-library marker; CrossOver skip-list (parameterised) and bottle scanning on a temp tree; importer platforms,
idempotent re-scan, title linking of bundle-less games, launcher-wins dedupe, install-vs-existing-title skip,
unreadable folders; view model add/remove/persist/scan; `TitleNormalizer`.
**Final count: 164 tests in 40 suites, all passing.** Lint (SwiftFormat + SwiftLint strict) clean.

**Stubbed / unverified**
- Not run against the owner's real `~/Switch/Games`, CrossOver bottles or launcher folder — verified with temp
  directory trees and mocks only. CrossOver launcher internals were not inspected; they are treated as ordinary `.app`s.
- The skip-list is heuristic: an unusual game exe (e.g. one named `…Service.exe`) could be missed, and an unlisted
  tool folder could import as a game (remove it from the library; re-scans will then re-add it — a future
  "ignored items" list would fix that).
- Title linking takes the first bundle-less game with a matching normalised title; duplicates titles in the logbook
  would link only one.
- Scans of the configured folders are not cancellable; the depth limit keeps them short.

## 9 · feature/library-dedupe
Branched from `feature/folder-import`. Owner request: the logbook import (141 games) left the 17 Switch ports
duplicated, once from the folder scan and once from the import.

**Built**
- **Merge engine (`GameMerger`, `LibraryDeduplicator`):**
  - Groups entries by normalised title. Entries pointing at two different bundles or Steam apps are never merged.
  - The richest entry survives and keeps its ID. It gains the duplicate's tracked `.app` path, sessions, Steam
    data and missing dates.
  - Series entries and collections are repointed, and the HLTB estimate moves (`HLTBProviding.reassign`).
  - The duplicate is then deleted. Playtime sources are never summed.
- **"Merge Duplicate Games…" (Library menu):** a preview sheet that lists each group and what it keeps, then merges
  on confirmation. This is the one-click fix for the existing 17 pairs. Nothing is merged without that click.
- **Future-proofing:**
  - The same pass runs after every library import (`ImportSummary.duplicatesMerged`) and every folder scan
    (`FolderImportSummary.duplicatesMerged`).
  - Steam sync links to an existing entry without a Steam app by title instead of adding a new one
    (`SteamSyncSummary.linked`).
- **HLTB id:** `Game.hltbID` / `GameRecord.hltbID` (optional, so older archives still decode). With an id,
  "Look Up on HowLongToBeat" opens the game's own page.
- ADR 0011.

**Tests:** J.R's exact scenario (scanned + imported → one entry with both sets of data and series repointed),
preview without changes, no merge across different bundles or Steam apps, HLTB move, import-time merge, Steam title
link and the view model. **171 tests in 42 suites, all passing.** Lint clean.

**Unverified:** not run against J.R's real store. Run Library → Merge Duplicate Games… once to fix the existing
17 pairs, then check the preview count is 17.

## 10 · feature/steam-provenance
Branched from `feature/library-dedupe`.

**Built**
- **Detection (`SteamInstallScanner`):**
  - Reads `appmanifest_*.acf` from Mac Steam and every library in its `libraryfolders.vdf`.
  - Does the same for each CrossOver bottle's Windows Steam. Windows library paths are resolved through `drive_c`
    or `dosdevices`.
  - Steam runtimes and redistributables are ignored.
- **Recording (`SteamProvenanceApplier`):**
  - Runs as part of "Scan Game Folders" and reports Mac / CrossOver install counts.
  - Each game gets `steamInstalls` (Mac and/or bottles, both allowed) and `installSizeBytes`. These are recomputed
    on every scan.
  - Games are matched by app ID, then linked by title. Installed games that aren't in the library are added.
- **Details:** a Steam section lists "Steam (Mac)" and "Steam (CrossOver — <bottle>)", each with its own Launch button.
- **Launch routing (new `Features/Launch`):**
  - `LaunchPlanner` puts the tracked `.app` first (NSWorkspace; the playtime watcher is started), then
    `steam://rungameid/<id>` for Mac, then CrossOver `wine --bottle … --cx-app C:\…\steam.exe -applaunch <id>`
    for bottles.
  - With no target, launching is honestly unavailable and the reason is shown.
  - `WorkspaceGameLauncher` is live; `RecordingGameLauncher` is the mock.
- ADR 0012.

**Tests:** scanner on a temp tree (Mac + extra library + bottle + `C:` library, redistributables ignored),
KeyValues and Windows path conversion, applier (both locations on one entry, title link, add, stale clear),
planner ordering and exact CrossOver arguments, Mac fallback, unavailable reasons, view model launch and error
paths, and the folder-scan integration. **183 tests in 45 suites, all passing.** Lint clean.

**Unverified:** no real Steam or CrossOver on the build machine was exercised. The CrossOver wine command line
(`CrossOverLaunchConfiguration`) is based on CrossOver's documented CLI and needs one real try. Steam libraries on
drive letters other than `C:` rely on the bottle's `dosdevices` links.

## 11 · feature/launch-ui
Branched from `feature/steam-provenance`. J.R's Playnite layout is the reference; launching comes first.

**Built**
- **Icon rail** (`IconRailView`, `RailItem`, `RailItemRow`): icons only, expanding to labels and section counts on
  hover. It floats over the content, so the grid doesn't reflow. It replaces the split-view sidebar.
- **Poster grid** stays the default view. Under each poster: title, platform plus per-source playtime, and status.
  Right-click lists every launch route ("Play", "Play via Steam (Mac)", "Play via Steam (CrossOver — <bottle>)"), or
  a disabled "Play" when there is none.
- **Details** (only after a click), in three columns:
  - Left: `GameQuickList`.
  - Centre: hero media slot, genre chips, description, then series / playtime / sessions / Steam provenance /
    achievements / guides.
  - Right: cover, the big **Launch** button (primary action plus a menu of alternatives; disabled with the reason
    when there's no target), **Manage…** (status, self-reported hours, cover and hero image, tracked app, HLTB
    entry), HLTB chips (Main Story / Main Story+ / Completionist, labelled "HLTB estimate"), and the info list
    (Status / Install Size / Time Played / Developer / Source / Release Date / Date Added / Platform / Tags).
- **Launching:**
  - `.app` launches go through NSWorkspace and start the playtime watcher, so the session is recorded as MacTracked.
  - Steam launches go to Mac Steam or the right bottle (ADR 0012).
  - With no target, the button is disabled and gives the reason.
- **Metadata:** new optional `developer`, `genres`, `tags`, `heroImagePath` (archive round-trip; merged on dedupe).
  Folder scans now measure `.app` bundle sizes for the Install Size row.
- Tokens: `DesignTokens.Rail`, `DesignTokens.Details`, `Typography.launch`. New `FlowLayout` component for chips.
  ADR 0013.

**Tests:** info list fields and order, per-source "Time Played" (never merged), source labels, grid caption, HLTB
chip names, metadata merge and archive round-trip, bundle size. **189 tests in 46 suites, all passing.** Lint clean.

**Unverified:** the build machine has no screen-recording permission, so the new layout was **not visually checked**.
The app launched and ran without a crash. Hover expansion, the three-column proportions and the Launch menu need one
look on a real screen. Genres, developer, tags and hero images have no automatic source yet; they come from the
import or the Manage sheet.

## 12 · feature/metadata-artwork
Fills metadata and official artwork per game (ADR 0014). 232 tests (+43), all on mocked HTTP or recorded
fixtures.
- ✅🧪 **Fetch Missing Metadata** (Library File menu). It fills empty fields from the Steam store `appdetails`
  endpoint (no key needed): description, developer, genres, categories as tags, release date, the 600×900
  portrait capsule, the library hero, and a carousel of screenshots and trailer thumbnails.
- ✅🧪 **SteamGridDB fallback.** It is used only for a cover or hero that is still missing, and only with J.R's
  key, which he pastes once in **Settings → Artwork** and is stored in the Keychain. NSFW, humour,
  epilepsy-risk, animated and blurred art is filtered out.
- 🟡 **Nintendo eShop:** the provider, mapper and matching rules are built and tested, but **no live source is
  connected**. Nintendo has no public API, and the store's internal search key was not used (no scraping). For
  now, Switch ports without a Steam twin get their art from SteamGridDB.
- ✅🧪 **Matching:** app ID first, then an exact `TitleNormalizer` match. If nothing matches, or two different
  items match, the field stays blank.
- ✅🧪 **Field rules** (`MetadataFillPolicy`):
  - Fields set by the user, and manual art, are never overwritten. Choose Cover… and Choose Hero Image… mark the
    field as user-set, and older art with no recorded source is treated as manual.
  - Imported descriptions are replaced only when empty, or by **Refresh Metadata** in Manage.
  - Playtime is untouched.
- ✅🧪 **Provenance** is recorded per field, shown in Manage → Metadata, exported and imported with the library,
  and kept through duplicate merges.
- ✅🧪 **Cache:** images are downloaded once into `~/Library/Application Support/Playrite/Artwork/<game-id>/` and
  rendered from disk. A download that isn't a real image (an HTML error page, say) is never cached.
- ✅ **Hero carousel:** the details hero now steps through the hero image and the carousel slides.
- ✅🧪 **Rate limiting:** games are processed one at a time, with per-host request spacing.
- ✅🧪 **Summary:** each pass reports filled, skipped and failed counts per source.
- ⚠️ **Not verified live:** no request has been made to the real Steam store or SteamGridDB, and the hero carousel
  hasn't been checked on screen.

## Status by branch (stacked, merge in this order)
| # | Branch | Built | Compiles | Tests | Pushed |
|---|--------|-------|----------|-------|--------|
| 0 | `feature/project-foundation` | ✅ | ✅ | 1 | ✅ |
| 1 | `feature/library-core` | ✅ | ✅ | 22 | ✅ |
| 2 | `feature/steam-provider` | ✅ | ✅ | 47 | ✅ |
| 3 | `feature/playtime-tracking` | ✅ | ✅ | 63 | ✅ |
| 4 | `feature/series-collections` | ✅ | ✅ | 79 | ✅ |
| 5 | `feature/stats-badges` | ✅ | ✅ | 92 | ✅ |
| 6 | `feature/nxnative-module` | ✅ | ✅ | 123 | ✅ |
| 7 | `feature/guides-hltb` | ✅ | ✅ | 142 | ✅ |
| 8 | `feature/folder-import` | ✅ | ✅ | 164 | ✅ |
| 9 | `feature/library-dedupe` | ✅ | ✅ | 171 | ✅ |
| 10 | `feature/steam-provenance` | ✅ | ✅ | 183 | ✅ |
| 11 | `feature/launch-ui` | ✅ | ✅ | 189 | ✅ |
| 12 | `feature/metadata-artwork` | ✅ | ✅ | 232 | ✅ |

Test counts are cumulative. On every branch, `./scripts/build.sh` gives BUILD SUCCEEDED and TEST SUCCEEDED,
`swiftlint lint --strict` reports 0 violations, and SwiftFormat is clean. The app was launch-checked on branches
1, 3, 7 and 8.

## Push & repo rename (2026-11-06) — blocker cleared
The owner switched `gh` to `studiojrba`. All nine `feature/*` branches were pushed with explicit
`refs/heads/feature/<name>` refspecs; **nothing was pushed to `main`/`master`** (neither exists on the remote).
The repo was then renamed with `gh repo rename`: **`studiojrba/Playrite` → `studiojrba/retriever`**. GitHub redirects
the old name. `gh` did not update the local remote (the rename used `--repo`), so `origin` was set by hand to
`https://github.com/studiojrba/retriever.git`. The local folder is now `~/Projects/Retriever`. The app and Xcode
target are still named Playrite; renaming them is a separate task.

`git ls-remote --heads origin` after the push (each tip matches the local branch):

| Branch | Tip | Result |
|--------|-----|--------|
| `feature/project-foundation` | `1963563` | ✅ pushed, matches |
| `feature/library-core` | `7f3e215` | ✅ pushed, matches |
| `feature/steam-provider` | `879abbd` | ✅ pushed, matches |
| `feature/playtime-tracking` | `344cc00` | ✅ pushed, matches |
| `feature/series-collections` | `cbbf190` | ✅ pushed, matches |
| `feature/stats-badges` | `aedcdf9` | ✅ pushed, matches |
| `feature/nxnative-module` | `d4bb007` | ✅ pushed, matches |
| `feature/guides-hltb` | `c731aa5` | ✅ pushed, matches |
| `feature/folder-import` | `b2a2bc7` | ✅ pushed, matches |

Because the remote had no `main`, GitHub first made **`feature/project-foundation`** the default branch. This was
replaced by `production`; see the next section.

## Default branch: `production` (2026-11-06)
At the owner's request, the default branch is named **`production`**, not `main`. **No `main` branch was created**,
and none should be.
- `production` was created at the tip of `feature/launch-ui`, which contains the whole stack (branches 0–11), including
  the commit that adds this note.
- It was pushed to `origin` and set as the repo default with `gh repo edit --default-branch production`.
- Open PRs into `production`, in stack order 0 → 11. Don't commit to `production` directly; it changes only through
  merged feature branches.

## Key decisions (see `docs/decisions/` ADR 0001–0014)
- Empty upstream repo, so the feature branches are **stacked**. The default branch is `production`; there is no `main`.
- XcodeGen (`project.yml`). The `.xcodeproj` is git-ignored; generate it with `./scripts/bootstrap.sh`.
- One app module with strict feature folders. Every service is protocol-first, with a mock for previews and tests.
- Views are driven entirely by design tokens and built from small components, ready for a Figma re-skin
  (enforced by a SwiftLint custom rule plus a manual audit).
- Playtime is stored per source and never merged; badges use real data only; HLTB is always labelled
  "HLTB estimate".
- The Steam key lives only in the Keychain. NXNative is off by default, never bundles anything, and cannot
  delete files (it has no delete API, and a policy test checks this).
- No scraping anywhere: GameFAQs guides are link-out only, and HLTB uses manual entry plus a link-out because
  there is no official API.

## Stubbed / not verified automatically
- Live Steam calls and the real Keychain wrapper. No key was available; both are covered with mocks.
- The live NSWorkspace observer and `ProcessBuildEngineRunner` against a real engine. No engine was available;
  both are covered with mocks and checked with a build and a launch.
- The nxnative CLI contract is unknown. Arguments are a configurable template, title metadata is entered manually,
  and the troubleshooting patch is an editable template.
- Automatic HLTB lookup is intentionally not implemented. The `HLTBRemoteSearching` seam is ready.
- A live Nintendo eShop metadata source (ADR 0014), extra providers, and the Figma visual pass are future work.

## Next steps
1. Open PRs into `production` in order 0 → 12 (`production` is the default branch; there is no `main`).
2. **GitHub Actions CI** (`feature/ci`, planned in `docs/PLAN.md`): run lint, build and test on pull requests,
   on a macOS runner.
3. Manually smoke-test the Steam flow with a real key, and the NXNative flow with the real engine.
4. Re-skin from Figma by changing tokens and components only.
