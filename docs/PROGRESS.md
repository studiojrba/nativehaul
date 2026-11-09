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
  folder or a sibling port marker (a legacy marker or `.nxnative-lib`) → `switchPort`; CrossOver launcher → `other`;
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

- ✅ **Verified live by Ollie (2026-11-06):**
  - The library holds 124 games (109 Backlog, 11 Abandoned, 4 Playing). The automatic merge had already folded
    the 17 duplicate pairs, most likely during J.R's onboarding folder scan, and Merge Duplicate Games reports
    none left.
  - The Breath of the Wild survivor carries both halves: the import's status, description and series, plus the
    local app source, its 18.76 GB install size and the native-port platform.
  - Self-reported hours are intact at 66h 42m.

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

## 13 · feature/steam-signin
Adds "Sign in through Steam" and a guided API key step (ADR 0015). 256 tests (+24), all mocked.
- ✅🧪 **Explicit states** in Settings → Steam and on the Steam screen: **Not signed in** → **Signed in · API
  key needed** → **Ready to sync**.
- ✅🧪 **Sign in through Steam:**
  - Uses Steam OpenID in `ASWebAuthenticationSession`.
  - The reply is fully checked locally, then confirmed by Steam with `check_authentication`. Only then is the
    SteamID64 stored.
  - The copy says plainly that sign-in only confirms the account and gives no access to the library.
- ✅🧪 **Guided key step:**
  - J.R's explanation of why a key is needed, then four numbered steps, including a button that opens
    steamcommunity.com/dev/apikey.
  - Paste → Save puts the key in the Keychain, then checks it with one `GetPlayerSummaries` call, which shows the
    account name and avatar.
  - A rejected key isn't kept, and the screen says so. **Sync Now** appears once the setup is ready.
- ✅🧪 **Private profile:** the screen says plainly that game details are private, names the exact settings
  (Game details → Public; untick "Always keep my total playtime private"), and links to Steam's privacy page.
- ✅🧪 **Manual fallback** for the SteamID64 and key, under "Enter details manually".
- ⚠️ **Not verified live:** the sign-in has not been run against Steam. Steam may refuse the custom-scheme
  return URL (`retriever://`); ADR 0015 describes the fallback. The flow hasn't been viewed on screen.

## 14 · feature/bottle-automation
Adds one-click Windows Steam installs through CrossOver, with a golden bottle (ADR 0017), and adopts the
**zero-tinker defaults** rule (ADR 0016, now in `CLAUDE.md`). Tests mock the CrossOver command line, the file
system and HTTP. 283 tests (+27).
- ✅🧪 **Recipes:** a versioned, bundled `BottleRecipes.json` with seven seed titles (three that work or mostly
  work, four blocked by anti-cheat) and an untested default. Recipes are applied per game, in each game's own
  bottle.
- ✅🧪 **Golden bottle:**
  - A lean bottle whose Steam is signed in to the SteamID linked in Retriever is adopted automatically.
  - Otherwise Retriever offers to set up Steam in CrossOver, in J.R's words. Accepting creates "Retriever
    Steam", installs Valve's SteamSetup silently, and the user signs in once in Steam's window.
- ✅🧪 **Download:**
  - Clones the golden bottle into "Retriever – <title>", then backs up `cxbottle.conf` and applies the recipe.
  - Runs `steam.exe -applaunch <id>` and watches the appmanifest, showing percent progress.
  - Records the bottle install, so Launch routes to it.
- ✅🧪 **Lost Steam session:** the screen says "Steam needs a sign-in in this bottle" once, with Open Steam,
  then stops with the reason. It never loops and never asks for credentials.
- ✅🧪 **Gates:**
  - A verdict blocked by anti-cheat or known to be broken shows the reason instead of a button.
  - CrossOver missing → a link to CodeWeavers.
  - Free space must cover the game plus Steam (the size is labelled when it's an estimate).
  - Golden bottle not ready → the offer.
- ✅🧪 **Zero-tinker audit:**
  - At launch, Retriever quietly scans for installed games, syncs Steam when it's set up, and fills missing
    metadata.
  - Steam syncs by itself once the key checks out.
  - Metadata runs after library changes, skipping games already tried this session.
- ⚠️ **Not verified live:** no real CrossOver was used. The `--clone` syntax, the graphics-backend key, `winecfg
  -v` and the silent Steam install are unverified and each kept in one place. The panel hasn't been viewed on
  screen.

## 15 · feature/onboarding
Adds the first-run walkthrough (ADR 0018). 291 tests (+8).
- ✅🧪 **Screens:** "Hey! I'm Retriever." → what it does → the trust block (shown before any setup) → the
  checklist hub with J.R's reassurance → a step for each checked module, in order → a Done screen with what's
  set up, what was skipped and where to find it later.
- ✅ **Modules** reuse their existing flows: Find your games (pre-checked), Steam sign-in plus the key steps,
  CrossOver detection plus the golden-bottle offer, and the Switch ports folder. Emulators show as "coming soon";
  the next branch wires them in.
- ✅🧪 **Skipping:** one click ("Set up later"), remembered, never nags. It can be re-run from Settings → General.
- ✅🧪 **Zero-tinker:** `~/Switch/Games` is scanned automatically when it exists, even with no folders
  configured, so someone who skips setup still has their games found.
- ⚠️ **Trust copy:** the repo had **no LICENSE file**, so "completely open source" needed one. Resolved in
  branch 20 (MIT). The folder line is qualified to be accurate (see ADR 0018). The walkthrough hasn't been viewed
  on screen.

## 16 · feature/emulator-launch
Adds emulator support as a launch route (ADR 0019), and records two project rules in `CLAUDE.md`: **shelf and
router, never the engine**, and **user-provided files**. 304 tests (+13), all mocked.
- ✅🧪 **Profiles:**
  - RetroArch is the default, with a core per system. PCSX2 is the default for PS2.
  - Dolphin, melonDS and PPSSPP are also seeded. Only emulators with documented launch syntax are seeded; the
    model is open for more.
  - Per-system overrides are in Settings → Emulators (optional).
- ✅🧪 **ROM library:**
  - The existing Game Folders scan also finds ROMs. The system comes from a unique extension, or, for shared
    ones like `.iso` or `.chd`, from a folder name. If the system can't be told, the ROM is left out.
  - Each ROM becomes one entry; re-scans add nothing.
  - A ROM entry never merges with a Steam or Mac game of the same title.
- ✅🧪 **Launch route:**
  - "Play in RetroArch" opens the emulator with the core and the ROM.
  - Honest states: the emulator isn't installed (with its official page), the core is missing (pointing to
    RetroArch's Core Downloader), or the ROM is missing.
- ✅🧪 **Playtime:** the next launch of the emulator is credited to the ROM, so emulated play counts like any other
  route.
- ✅🧪 **"Please provide your PlayStation 2 BIOS":** one reusable prompt (`ProvideFilePrompt`) that copies the user's
  own file into PCSX2's BIOS folder without overwriting. It gives no sources, links or hints.
- ✅ **Metadata** for ROMs comes from SteamGridDB; the Steam store isn't asked.
- ✅ **Onboarding** gains a working Emulators step.
- ⚠️ **Not verified live:** no emulator or core was run. The argument syntax follows each emulator's documented
  command line. NXNative's `prod.keys` moved to the prompt in branch 19.

## 17 · feature/component-updates
Adds managed components and update badges, Obtainium-style, per source (ADR 0020). 319 tests (+15), all mocked.
- ✅🧪 **Component catalog** (`ComponentCatalog.json`, versioned and community-extendable): melonDS and PCSX2 come
  from GitHub releases with a macOS asset pattern; RetroArch and Dolphin from pinned official URLs. Everything
  installs into `~/Applications`, so there are no admin prompts.
- ✅🧪 **Install** (from Settings → Emulators and onboarding):
  1. Download from the official source only, and check the published SHA-256 when there is one.
  2. Unpack, then ask macOS about the signature and **show it to the user** ("Signed by <team>, notarized" or
     "Unsigned — macOS will ask you to confirm").
  3. Install on a second click.
  4. The installed app keeps the quarantine flag, so Gatekeeper still checks it.
  5. The emulator profile is wired automatically.
- ✅🧪 **Update checks:**
  - GitHub's latest release, or the pinned version, compared with the app's bundle version.
  - At most once a day (cached), from launch upkeep or **Check Now**. No daemon.
  - Copies the user installed themselves get "Update available", then "Manage and Update" (asked first).
- ✅🧪 **Auto-update is off by default.** It can be turned on globally or per component. Even then, it installs
  only when the update is notarized by the same team as the installed copy; otherwise it waits for a click.
- ✅🧪 **Game badges, per source:**
  - **Steam** (Mac and bottles): a pending update or download percentage, read from the appmanifest. Steam does
    the updating; Retriever never updates a game.
  - **Switch ports:** the built version is compared with a community dataset (ships empty), using J.R's copy:
    "An update is available! Please refer to your original source for update files." nxnative builds now
    record the title ID and version.
  - **ROMs:** no badge.
- ✅ **Retriever self-update:** notify-only release check (seam). Sparkle waits for signed release builds.
- ✅ **Hard lines:** Retriever never downloads ROMs, BIOS files or firmware. A BIOS uses the "Please provide your ___"
  prompt.
- ⚠️ **Not verified live:**
  - No real download or install was run, and the pinned RetroArch and Dolphin URLs need checking by whoever
    maintains the catalog.
  - `ISteamApps/UpToDateCheck` was judged not feasible (it needs `steam.inf`'s version, not the appmanifest's
    `buildid`), so stale bottles show their last-known state.
  - The update surfaces haven't been viewed on screen.

## 18 · feature/steam-signin-loopback — QA Finding #1 fix
**Ready for J.R to retest now:** onboarding → Steam → Sign in through Steam.
- 🐞 **Found live by J.R** (screenshot verified by Ollie): Steam replied "Invalid return protocol." Steam's OpenID
  accepts only http(s) return addresses, so the `retriever://` callback from branch 13 could never work against
  real Steam. The mocked tests passed because they never reached the real endpoint.
- ✅🧪 **Fix:** a loopback redirect (RFC 8252), amended in ADR 0015.
  - A one-shot listener on **127.0.0.1**, on a port the system picks.
  - `return_to=http://127.0.0.1:<port>/steam-openid/callback` and `realm=http://127.0.0.1:<port>/`.
  - Sign-in opens in the user's browser. The listener catches Steam's redirect and shows "you can close this
    tab", then the reply is validated and confirmed with `check_authentication` as before, and the listener
    shuts down.
- ✅🧪 **Honest states:** a timeout (also covers a closed tab), a Cancel button while waiting, the listener failing
  to start (points to manual entry), and Steam's own cancel.
- ✅ Everything stays on the device: no hosted redirect domain. The manual SteamID + key fallback is unchanged.
- ✅🧪 **Tests:** loopback URL construction (always http and 127.0.0.1, never a custom scheme), and the real loopback
  listener's lifecycle (one-shot, stray requests get 404, timeout, cancel, distinct ports, full round trip).
  327 tests (+8).
- ⚠️ Pending J.R's live retest. Steam's page should now show the 127.0.0.1 realm and return to the app.

## 19 · feature/nxnative-file-prompts
Moves NXNative's user-provided files onto the shared **"Please provide your ___"** prompt (ADR 0019 amendment;
approved by J.R when he set the rule). 333 tests (+6).
- ✅🧪 **prod.keys:**
  - A new preflight check fails with "Please provide your prod.keys." The build job's screen then shows the prompt
    and copies the user's own file (never overwriting) to `~/.switch/prod.keys` by default; this is configurable
    via `keysPath`, and older stored settings still load.
  - The engine can receive the path through the `{keys}` placeholder. Preflight re-runs automatically.
- ✅🧪 **Game file:** the Add Build sheet now asks "Please provide your game file (.nsp/.xci)", and the picker is
  limited to Switch title files. The file is used where it is.
- ✅ No sources, links or hints anywhere. The prompt gained `destinationFileName` and `allowedExtensions`.
- ⚠️ Whether J.R's engine reads `~/.switch/prod.keys` by default depends on the engine. `keysPath` and `{keys}`
  cover it either way. Not viewed on screen.

## 20 · feature/mit-license
- ✅ `LICENSE` added at the repo root: standard MIT text, "Copyright (c) 2026 Studio Jrba inc." (J.R's decision).
  `README.md` gains a one-line License section pointing at it.
- ✅ This closes the gap flagged in branch 15: onboarding's "Completely open source" line is now strictly true.
- No other release prep. J.R's "no release prep yet" rule still stands.

## 21 · feature/detail-layout-fit — QA Finding #2 fix
- 🐞 **Found live by J.R** (screenshot reviewed by Ollie; this was the launch UI's first real visual check): the
  detail page overflowed the window. The right rail was clipped (Play running off, the helper text cut
  mid-sentence, Manage and the info values cut at the edge), quick-list titles were clipped mid-word, and the
  centre took more than its share.
- ✅🧪 **J.R's layout contract, now the spec:** contents always fit inside the window and are never cut off. The
  games list (left) and the rail (right: cover, Play, Manage, HLTB chips, info list) are fixed-width parents that
  stay fully visible. The centre is the child: it takes whatever width is left, wraps its text, its Up Next cards
  reflow, and vertical scrolling absorbs the rest.
- ✅ **What changed:**
  - **Side columns:** fixed widths with higher layout priority. The centre is `minWidth 0`, `maxWidth .infinity`.
  - **Hero:** the main culprit. A `scaledToFill` image reported its natural width and pushed the row wider than
    the window. It now fills an overlay instead.
  - **Up Next:** the cards wrap onto new rows (a `FlowLayout`) instead of an intrinsic-width row.
    `FlowLayout` now never places an item wider than its row.
  - **Wrapping:** section headers, session rows and guide rows wrap. The title, description, info values and
    quick-list titles (up to four lines) wrap instead of clipping.
  - **Play:** the button reads "Play", and the route ("via Steam (CrossOver — …)") wraps underneath it. The
    helper text wraps.
  - **HLTB chips:** labels shrink slightly rather than clip.
  - **Minimum window width:** lowered from 960 to 800 so 900 px is reachable. The layout adapts on its own merits
    and doesn't rely on the minimum.
- ✅🧪 **Verified** by measuring the laid-out detail page at **900, 1100 and 1280 px** (default) with long titles,
  genres, descriptions and a long bottle name: nothing is wider than the window. Rail and centre parts are also
  checked at narrow widths. Offscreen renders at each width were inspected by eye. 336 tests (+3).
- ⚠️ Pending J.R's look on his real window.

## 22 · feature/hltb-cache-read — QA Finding #3 fix
- 🐞 **Found live by Ollie:** `~/Library/Application Support/Playrite/HLTB/estimates.json` was intact (109
  entries), but Stats showed "0 of 109" and the detail chips had no values.
- 🔎 **Root cause:**
  - **Not** the path, the envelope, the field names or the keys; all of those matched.
  - `HLTBEstimate.seconds` is `[HLTBCategory: Int]`, and Swift's synthesized Codable stores a dictionary keyed by
    an enum as a **flat array** (`["mainStory", 182220, …]`), not a JSON object. The documented file uses an
    object (`{"mainStory": 182220, …}`), so every entry failed with a type mismatch.
  - The service loaded the file with `(try? cache.load()) ?? [:]`, so the failure was **swallowed into zero**.
- ✅🧪 **Fix:**
  - `seconds` is now read and written as a JSON object keyed by category name (the documented format). The old
    flat-array form is still read, so files saved by earlier builds keep working.
  - One unreadable entry is skipped and counted instead of failing the whole file.
  - **Failures are shown, not hidden:** Stats and the HLTB section show the problem in plain words, for example
    "The HLTB estimates file couldn't be read (it isn't a list of estimates). It was left as it is."
  - Before the app ever saves over a file it couldn't fully read, it copies the original to
    `estimates.json.unreadable-backup`, so a manual entry can't wipe good data.
- ✅ **The existing file needs no changes.** The current format is exactly the one on disk: a bare JSON array of
  `{gameID, title, seconds: {mainStory, mainExtras, completionist}, recordedAt (ISO-8601), origin}`. All 109 real
  entries were checked read-only against the new decoder's rules, and none would be skipped.
- ✅🧪 Tests cover the exact on-disk shape, the legacy format, the object form on save, a bad entry being skipped
  and reported, an unreadable file being reported and backed up, and Stats showing the problem. 342 tests (+6).
- ⚠️ Pending Ollie's live recheck: Stats should report 109 of 109 backlog games with an estimate, and the chips
  should show values.

## 23 · feature/nxnative-on-by-default — J.R product correction
- 📣 **J.R product correction (spec change):** the live Builds page said "NXNative Module Off — Enable the module
  and choose your own engine in Settings…". J.R: NXNative is **100% on by default**; only user-provided files
  (prod.keys, a game file) aren't, and the module must be ready for users who already have them.
- ✅🧪 **On by default:** fresh installs are on. Untouched existing installs (their saved `isEnabled: false` was
  only the old default) migrate to on, J.R's included. An explicit off in Settings is stored as
  `isSwitchedOffByUser` and respected, and the page then offers **Turn On**.
- ✅🧪 **Engine auto-detection** (`NXNativeLocator`, search list in ADR 0021): `~/Switch` tools, then nxnative
  checkouts (at the time including another app's bundled copy, J.R's engine then; removed by ADR 0027), then `~/bin`,
  Homebrew and similar folders. The Settings path is an override only. With no engine anywhere, the page still opens,
  with a "No nxnative engine found on this Mac" banner and **Choose Engine…**.
- ✅🧪 **prod.keys auto-detection:** `~/Switch/ProdKeys/prod.keys`, then other `~/Switch/ProdKeys…` folders
  (J.R's real keys are in `~/Switch/ProdKeys.NET-v22.5.0/`), then `~/.switch/prod.keys` and the other usual spots.
  "Please provide your prod.keys" appears only when none exist. The game file stays per build in Add Build.
- ✅ The old "enable the module / choose your engine in Settings" copy is gone (view deleted). CLAUDE.md records
  the rule beside zero-tinker: **features ship on; only user-provided files gate them; files the user already has
  are detected, not re-demanded.**
- ✅🧪 Tests cover: fresh-state on; untouched-install migration to on; explicit off respected (and Turn On);
  key-detection order, including `~/Switch/ProdKeys` and versioned `ProdKeys…` folders; silent use of detected
  keys versus the prompt when none exist; engine detection order and overrides; and the engine-not-found copy.
  357 tests (+15).
- ⚠️ **Found, not fixed (follow-up):** detection finds J.R's nxnative, but a build won't run with zero edits yet:
  - nxnative's command line (`build_ipa_from_nsp.py <game folder> -k <keys> --platform mac-app -o <app>`) doesn't
    match the default argument template, and the script needs its own Python environment;
  - J.R's games use a different library marker than the default `.nxnative-lib`.
  - → Fixed on branch 24 (`feature/nxnative-derived-invocation`, ADR 0022).
- ⚠️ Pending a live recheck: J.R's Builds page should open enabled, and Settings should show both paths as
  "found automatically".

## 24 · feature/nxnative-derived-invocation — last blocker before Phase 1's first test
- 📣 **Context:** Ollie verified ADR 0021 live (the Builds page opens ready; the engine and the
  ProdKeys.NET keys are detected). J.R scheduled the first nxnative test through Retriever: a Switch 2 game
  downloading tonight. **This branch clears the last blocker:** a detected engine now builds with zero Settings edits.
- 🔎 Read-only research on J.R's machine (how nxnative's build script is driven, nxnative's `-h` and input
  handling, his game folders). The command shape was confirmed live through the checkout's Python, with nothing
  built.
- ✅🧪 **Derived invocation** (`NXNativeCheckout`) for a detected or hand-picked nxnative checkout with the default
  template:
  - **Command:** `<checkout .venv>/bin/python3 scripts/build_ipa_from_nsp.py <game> [-k <keys>] --platform mac-app
    -o <work>/<Title>.app`.
  - **How it runs:** from the checkout, with `VIRTUAL_ENV` set and `PATH` starting with the venv, then mise and
    Homebrew. stdin is closed, so nothing can hang on a prompt.
  - **Without the checkout's environment:** the system python3 is used, and preflight shows a warning.
- ✅🧪 **Switch 2 shape:**
  - Add Build gains "Please provide your Switch 2 game (its folder or .nup)".
  - Dump layouts follow nxnative's `is_dump`. Packages beside a dump are built as packages.
  - No `-k`, and the keys check reads "Not needed for a Switch 2 game."
  - The title ID may be blank (nxnative reads it). `04…` IDs count as retail.
  - Free space is measured over the whole folder.
- ✅🧪 **Library:** a detected checkout files one folder per game. Cleanup files the app as
  `~/Switch/Games/<Title>/<Title>.app` and creates the empty marker beside it, like J.R's existing games, never
  overwriting.
- ✅🧪 **Overrides unchanged:** a custom template or a non-checkout engine still uses the template,
  `.nxnative-lib` and a flat output.
- ✅🧪 **Tests:** both invocation shapes (package with keys; dump and `.nup` without), the environment and its
  fallback, overrides, shape detection, Switch 2 preflight with no keys and no title ID, the cleanup layout and
  marker, and a Switch 2 job end to end (queue → mock engine → cleanup → registered at
  `/games/<Title>/<Title>.app`). 373 tests (+16).
- ⚠️ **For tonight:** Retriever never unpacks archives. The multi-part set must be a dump folder or a `.nup` before
  Add Build; unpacking or joining it is J.R's step. The full build on his Mac (toolchain, time) is unverified until that
  first run.

## 25 · feature/folder-first-add-build — J.R requirement
- 📣 **J.R requirement ("super important", his favourite builder behaviour):** point Add Build at one folder with
  a random mix of base, update and DLC files, and it sorts them by title ID, one click and go. Same for Switch 2.
  Folded in: **the Add Build pickers open in `~/Downloads`**, because that's where game files land.
  **Scope (J.R):** this applies to the build side only, meaning the picker for build inputs. Where games live and where
  built apps and work folders go remain the user's settings, unchanged (`~/Switch/…` defaults); a test checks that
  none of them defaults to Downloads.
- ✅🧪 **Folder-first sheet:**
  - The primary pick is a folder. A single file (`.nsp`/`.xci`/`.nup`) stays as the second option.
  - Before anything is queued, the folder is scanned and the result is shown: game name, title ID, and "Base game ·
    update vN · N DLC". Switch 2 games get the same at-a-glance summary (base, updates, DLC, or `.nup` version).
- ✅🧪 **Title IDs:** read from the `[0100…][vN]` file-name tags (J.R's real naming), otherwise from the ticket name
  or the plain `.cnmt.xml` in the package header. Only the start of the file is read, with no keys. Both header forms
  were checked on his real files.
- ✅🧪 **Grouping:** base `…000`, update `…800`, DLC = base + `0x1000` + n.
- ✅🧪 **One job per game:**
  - A folder holding more than one game lists each one with a checkbox, plus Select All.
  - Each chosen game is queued separately, and the engine gets `--title-id`, so games are never mixed.
  - Several `.nup` files are listed separately too.
- ✅🧪 **Plain failures in the sheet, nothing queued:**
  - "No game files found in this folder…";
  - "This folder has an update for Pikmin 3 Deluxe (0100F4C009322000) but not its base game." (J.R's real
    update-only folder);
  - a lone update or DLC file is refused.
  Updates or DLC without a base, beside a real game, are listed as "Skipped: …".
- ✅ **One click:** a single game is preselected and named from its file, architecture defaults to 64-bit, and the
  title ID may be blank for detected-checkout builds. The single Ocarina `.nup` still queues in one click.
- ✅🧪 Tests cover:
  - title-ID relationships;
  - mixed-folder grouping (One Piece Pirate Warriors 4: base, two updates, three DLC);
  - DLC counting;
  - a two-game folder (pick one or all, and `--title-id` in the invocation);
  - the update-only error copy, a lone update file, orphans skipped beside a game, and a folder with no game files;
  - the Switch 2 dump summary, a folder of several `.nup` files, and the lone Ocarina `.nup`;
  - identity from the ticket and cnmt.xml headers, and a malformed header;
  - both pickers starting in Downloads, while the game and output folders don't.
  391 tests (+18).
- ⚠️ Pending J.R's live try with a real mixed folder.

## 26 · feature/builds-inbox — J.R feature
- 📣 **J.R feature:** a watched folder (a builds inbox) so new game files can be queued with no file picker
  anywhere: builds startable without touching the Mac, and plain zero-tinker for everyone.
- ✅🧪 **Watches `~/Downloads` by default** from first run, with no picker and no setup. Settings → NXNative → Builds
  inbox can change the folder (**Use Downloads** goes back) or turn watching off. Older saved settings decode as
  watching Downloads.
- ✅🧪 **Detection** runs at launch, on folder changes (debounced kernel events), when the page appears, and on
  Refresh.
  - **Offered:** loose `.nsp`/`.xci` (grouped by title ID), loose `.nup` files, and subfolders holding a game. Each
    item gets the folder-first summary.
  - **Ignored:** archives (never extracted), unfinished downloads, `.app` bundles, and folders that can't be built
    (J.R's update-only Pikmin folder).
- ✅🧪 **Builds page:** a "New in Downloads" section at the top of the queue, with the plain watching line and Queue
  and Dismiss on each item. Queue goes through the derived invocation; there's no picker and nothing auto-builds.
- ✅🧪 **Dedupe:** queued jobs, built apps in the library (by title ID, or by name) and dismissed items don't
  reappear. Dismissals persist.
- ✅ **Wording:** the onboarding trust line now lists every place Retriever looks, including engine and keys
  detection (which it was missing) and Downloads. macOS's one-time Downloads prompt gets a plain purpose string.
- 🐞✅ **Test isolation:** the unit-test host was launching the live app (J.R's library and folders). Watching
  Downloads made the runner hang on the permission prompt. The app now starts nothing live while hosting tests.
- ✅🧪 Tests cover:
  - detection of a single `.nup`, a single `.nsp` and a mixed folder, with archives, partial downloads, apps and an
    update-only folder ignored;
  - the summary matching a folder pick;
  - folder-change refresh;
  - dedupe against the queue and the library;
  - dismissals persisting across launches;
  - the default Downloads, a Settings folder override, and watching off;
  - Queue → a job → the derived invocation, with no picker;
  - the section copy.
  402 tests (+11).

## 27 · feature/ui-polish — J.R moves the design phase forward
- 📣 **J.R's call:** "build something nice and ultra polished so I can see the changes when I wake up."
  Benchmarks from the design research:
  - Linear (tokens), Steam (poster grid), Infuse (detail hero), Steam Replay (Stats).
  - The colour amendment: one signature accent, art-derived tints, muted statuses.
  - The **(Not Boring) apps** as the character reference: "clean with pop".
  Visual only; no behaviour, data or navigation changes.
- ✅ **Tokens:** a `Palette` with dark and light pairs: canvas `#08090A`, surfaces `#101113` / `#16171B`,
  hairlines `#1F2023`, and a sidebar dimmer than the canvas. A 13 pt type scale with big tight rounded display
  type. Art-tint tokens. Views still contain no literals.
- ✅ **Signature accent "Fetch orange"** (`#FF5A1F` / `#F24E12`, near-black text on it), used on Play, the active
  rail item, selection, the app tint, links, empty-state symbols, Stats ranks and "Retriever" in the welcome.
  Structure stays neutral and statuses muted ("Playing" moved off the accent).
- ✅ **Grid:** title plus one quiet line ("66h 42m · SteamSynced", or the status), a hairline ring that brightens on
  hover, a faint hover wash from the card's own art, and no shadows or pills.
- ✅ **Rail:** verified as an overlay (it never reflows the grid). It now sits on the dimmer sidebar surface with a
  hairline edge instead of a shadow, and the active item uses the accent.
- ✅ **Detail:** an ambient hero glow sampled from the art (weak and behind everything), a display title, monochrome
  HLTB chips, hairlines instead of dividers, and the same rail sections with tighter spacing.
- ✅ **Stats:** leads with a ranked **Most played** row with art (each game's largest single real figure, never a
  sum), with the totals beneath.
- ✅ **Consistency:** one `EmptyStateView`, the canvas across screens, neutral outlined tags, display-size onboarding
  titles, and "Hey! I'm **Retriever**." at 44 pt.
- ✅🧪 **Renders:** the grid and detail page at 900, 1100 and 1280, plus Stats, the welcome and Builds, in dark and
  light with stand-in art. All were inspected, and fixes followed (glow edges, link colour, header captions).
  A curated set is in `docs/design/ui-polish/`.
- ✅🧪 Layout guards are green. New tests cover the card line, a ranking that never merges sources, statuses off the
  accent, a sidebar dimmer than the canvas, structural colours near-chroma-free with the accent the one saturated
  colour, and art-tint sampling and caching. 409 tests (+7).
- ⚠️ Not yet seen with J.R's real covers in a live window. The app rename stays queued after this.

## 28 · fix/remove-downloads-watcher — launch hang fixed by J.R's reversal of the builds inbox
- 🐞 **Found tonight (Ollie):** the 00:11 Debug build "wouldn't stay launched", with no crash report, which blocked
  the Phase 1 Ocarina test.
  - **Diagnosis**, from the stuck process and a stack sample: it was **a hang, not a crash, and not a store or
    migration issue.**
    - The main thread sat in the inbox watcher's `open(~/Downloads)` at launch, waiting on macOS's privacy check
      (each Debug rebuild has a new signature, so macOS asks again).
    - The window had been built ("All Games") but was 0×0 and never shown.
    - Relaunches re-activated the stuck instance.
  - J.R's real library was not touched.
- 📣 **J.R decision (00:28 EST):** scratch the Downloads watcher entirely. It's a protected folder; access follows
  the user's pick; never Full Disk Access. An off-main-thread watcher fix was in progress; it was dropped unpushed.
- ✅ **Removed:** the watcher (live and mock), default Downloads watching, the "New in Downloads" section, its view
  model, scanner and dismissals, the inbox config fields (old settings still decode), the Settings controls and the
  Downloads purpose string. The onboarding trust line is restored to its original wording.
- ✅ **Kept:** folder-first Add Build and its scanner (now with a test for skipping unfinished downloads), the Add
  Build pickers opening in Downloads (a user pick is consent), and the test host starting nothing live.
- ✅ **Rule recorded** in CLAUDE.md and ADR 0026 (superseding ADR 0024): nothing reads or watches a protected folder
  by itself, and nothing on the launch path touches one.
- ✅ ADR 0025 gains Ollie's Meebits deep-dive rules (monochrome chrome with one electric accent, colour from content,
  mono for data, near-zero hover, one motion gesture, pills and 16/20 px radii). Applying them is follow-up work.
  Item 7 arrived cut off.
- ✅🧪 The inbox tests are removed, and the scanner and grouping tests stay green. 399 tests; lint clean.

## 29 · fix/standalone-nxnative-only — J.R product rule
- 📣 **J.R product rule (00:35 EST):** Retriever must not be associated with other front ends for the engine. The
  engine is nxnative, full stop. He saw a preflight line pointing at a copy of nxnative bundled in another app's
  Application Support folder.
- ✅🧪 **Detection is standalone nxnative only:** `~/Switch` tools, then `~/Switch/nxnative`, then Homebrew. A
  Settings engine path is the user's own choice. Anything resolving inside an app bundle or Application Support is
  never detected, and other apps' tool names are gone from the search.
- ✅🧪 **No standalone engine** → the "No nxnative engine found on this Mac" banner and Choose Engine… The copy
  now reads "Retriever looked in ~/Switch and Homebrew."
- ✅ **The derived run uses only the checkout's own `.venv`** (or the system python3 with a warning pointing at
  nxnative's README). Checkout builds use Retriever's own `.nxnative-lib` marker. The scanner keeps a read-only
  constant for an older marker so existing ports stay recognised.
- ✅ **Wording:** no other front end is named in UI copy, preflight lines or docs (ADRs and PROGRESS reworded). The
  rule is in CLAUDE.md and ADR 0027.
- ✅🧪 Tests: the search order, a standalone checkout detected, **a machine with only another app's bundled copy
  reports no engine found**, the Switch folder ahead of Homebrew, and the readiness copy. 401 tests; lint clean.
- ⚠️ On J.R's Mac the only copy today is the app-bundled one, so the Builds page will show "No nxnative engine
  found" until a standalone nxnative exists or he chooses one. Tonight's Ocarina build finishes as-is.

## 30 · feature/builds-detail-showcase — J.R design direction for the Builds page
- 📣 **J.R direction (00:37–00:38 EST):** the job detail takes two thirds of the Builds page; a screenshot slideshow
  above the job title; one segmented progress bar for the build above the raw log.
- ✅🧪 **Layout:** queue one third, detail two thirds, as fixed parents (no splitter). A layout guard keeps the
  detail inside its share at 900, 1100 and 1280, and nothing overflows.
- ✅🧪 **Showcase:** official screenshots the metadata pipeline already cached for the matching library game (by
  title ID, then name). They advance every 3 s with a 0.8 s crossfade, loop, and pause on hover. There are no
  gestures, so build controls keep every click. Fallbacks: the hero as one still, or nothing (no empty box). It is
  a fixed 16:9 area, images decode off the main thread, and nothing shifts. Reduce Motion shows the first image
  still.
- ✅🧪 **Segmented progress:** the runner's lines are parsed into `BuildJob.progress` (nxnative's `[k/n]` starts,
  `91%, …, 1:00 · ETA 0:06` beats and `✓ [k/n]` ticks). Finished segments are full accent, the current one fills,
  upcoming ones stay on the track. Beside the bar: the stage name and "k of n", the overall percent and elapsed ·
  ETA in mono. The percent never runs backwards; a 5 → 6 re-plan re-segments and holds the percent. Without stage
  markers the bar is indeterminate. Reduce Motion lands values without animation. The log is unchanged below.
- ✅🧪 Tests:
  - parser: stage markers, percent lines, bare percent lines, the 5 → 6 re-plan, a percent that never drops within a
    stage, missing markers, a failed stage, and the last tick reaching 100%;
  - showcase source: screenshots, the hero fallback, no art;
  - off-main decode;
  - runner lines becoming structured state;
  - the layout guard at three widths.
  415 tests (+14); lint clean.
- ✅ **Renders:** the job pane mid-build at 900, 1100 and 1280 (dark and light), inspected; a set is in
  `docs/design/builds-page/`.
- ⚠️ The slideshow appears only when the game is in the library with cached art. Not yet seen live on J.R's Mac.

## 31 · feature/app-rename-retriever — J.R GO (18:54 EST)
- 📣 **J.R GO:** the app is renamed to Retriever. Bundle ID, the Application Support folder, the SwiftData store and
  the Keychain service stay frozen, and the library has to survive untouched. There is one canonical build output
  from now on. ADR 0029.
- ⚠️ The brief cited (`~/workspace/playrite/rename-brief.md`) was not on this Mac (there is no `~/workspace`). The
  requirements in J.R's message were used instead.
- ✅ **Retriever, user-facing:**
  - `CFBundleDisplayName` and `CFBundleName` are both Retriever, which covers the Dock, the menu bar app menu
    (About, Hide, Quit) and the Settings window title;
  - window titles come from the bundle;
  - every user-facing string that said Playrite now says Retriever, including the library export filename;
  - README, PLAN and CLAUDE.md are updated.
  The sidebar and onboarding had no app-name text left to change. Historical ADRs and PROGRESS entries keep their
  wording.
- ✅ **Filename `Retriever.app`: low risk, so done.**
  - `PRODUCT_NAME: Retriever` gives `Retriever.app` with a `Retriever` executable.
  - The module stays `Playrite` (`PRODUCT_MODULE_NAME`), so `@testable import` is unchanged, and `TEST_HOST` was
    updated.
  - No data depends on the filename. The library is in `~/Library/Application Support/default.store` (SwiftData's
    default, independent of the app name), and settings are keyed on the bundle ID.
  - The scanner skips both `Retriever.app` and `Playrite.app`.
- ✅🧪 **Frozen identifiers are in `AppInfo` and pinned by tests:**
  - bundle ID `com.studiojrba.Playrite`, folder `Application Support/Playrite`, store `default.store`, Keychain
    service `com.studiojrba.Playrite`;
  - tests also check the real artwork, HLTB, audit and backup paths, the SwiftData default store URL, and that the
    host bundle is `Retriever.app` with the frozen ID and display name.
  - Project, scheme, folders and type names stay `Playrite`, since they are internal.
- ✅ **One canonical build output.** `build.sh` now builds into Xcode's default DerivedData, the same folder Xcode
  uses, and prints the path:
  `~/Library/Developer/Xcode/DerivedData/Playrite-exinnpzvysdovkcwpocorbnjqrch/Build/Products/Debug/Retriever.app`
  The old second output (`build/DerivedData`, 587 MB, with a stale `Playrite.app`) was moved to the Trash, not
  deleted. Spotlight now finds exactly one app with this bundle ID outside the Trash. The rule is in CLAUDE.md.
- ✅ **Launch-verified against J.R's real library:**
  - the canonical `Retriever.app` opened on All Games with covers;
  - a copy of the store taken after the run shows 125 games, 2 guide links, 13 series and 3 collections, the same as
    the copy taken before;
  - the Ocarina switchPort entry still has its 18:51 macTracked session (2 min 29 s);
  - no `Retriever` Application Support folder was created;
  - the test instance was quit (Apple Event quit), and **no instance is left running**.
- ⚠️ **Tracking side effect of the verification launch:**
  - Ocarina was already running (launched 18:58:32, still running). The test instance recorded it as a session
    from 18:58:32 to 19:00:27, closed when the instance quit.
  - When the watcher starts and a game is already running, it dates the session from the game's launch time
    (`WorkspaceRunningApplicationObserver`). If Retriever is launched again while that same Ocarina process is still
    running, its new session will also start at 18:58:32, and about 2 minutes will be counted twice.
  - The watcher has always done this; it isn't new in this branch. J.R's store was not edited.
  - The 06:52 → 18:55 Ocarina session (about 12 h) looks like a related tracking issue worth checking.
- ✅🧪 419 tests (+4); lint clean.

## 32 · feature/nxnative-first-launch-guidance — QA Finding #6 follow-ups
- 🔎 **Finding #6 resolved:** the Ocarina port works. With its window in front it reached the title screen at 60 fps.
  The QA black screens came from the game pausing itself whenever it lost focus. Part of the fullscreen run's black
  screen was caused by this session's own test host and verification launch. There was no shader compile (0 pipelines
  compiled), and nothing was wrong in Retriever or the build. No hack was needed.
- ✅🧪 **Knowledge base:** new case `nxnative-game-black-screen`, "A built game shows a black screen", written for
  someone launching their first port. It covers:
  - the game only draws while its window is in front and focused;
  - a covered or unfocused game shows black, and its music may continue;
  - an intro movie can play black with sound, and the port's log may show "a packet refused with" lines;
  - a cold first open can take about 30 seconds behind the game's own progress screen.
  The steps are a new advice-only step kind, `checkGame` ("Mark Done"). It changes nothing on the Mac: no backup, no
  audit entry, no engine script. The case view hides the script, patch and revert controls for advice-only cases.
  Build logs never suggest this case. Doc page: `docs/troubleshooting/nxnative-game-black-screen.md`.
- ✅🧪 **Launch focus verified (ADR 0030):** after Play, Retriever never raises its own window, opens a sheet or alert,
  or takes focus from the game.
  - Play opens the game activated (`activates = true`, now in `WorkspaceGameLauncher.openConfiguration`).
  - Play's only feedback is inline text under the button.
  - No source activates the app, orders a window front, requests attention or opens a window.
  - The playtime watcher posts nothing.
  - Locked by `LaunchFocusTests`: games open activated; a source scan forbids focus-taking APIs; Play opens nothing.
  - No fix was needed.
  - ⚠️ Verified by code audit and tests, not by clicking Play live. There is no accessibility access on the QA Mac,
    and a live run would add a tracked session to J.R's real library.
- 📝 **Proposal, not built (ADR 0031): per-title launch recipes.**
  - If a title ever needs launch flags or environment overrides (like tonight's diagnostic `--no-launcher` and
    `DM_FULLSCREEN=0`), Retriever stores them per title (key: Switch title ID) and applies them invisibly on Play.
  - Sources: the user's override, then a reviewed bundled database.
  - Safety: arguments and environment only, an allow-listed `DM_*` set, audited.
  - Ocarina needs no recipe. This is the standing mechanism for a title that does.
- 📌 **Standing rule (J.R, 19:18 EST), recorded in CLAUDE.md:** games launch from inside Retriever, and QA user-flow
  tests launch through Retriever's Play button. A direct `.app` launch is a diagnostic only and is labelled as one.
  Tonight's `--no-launcher` Ocarina run was a **diagnostic**, not a user-flow test. CLAUDE.md also notes not to run
  the test suite while J.R is playing, because its test host is a second Retriever that takes focus.
- 📌 **Window by default (decided, J.R on Ollie's recommendation, 19:18 EST):**
  - New ports launch in Window mode, recorded in the ADR 0031 recipe proposal as a per-title display-mode field
    (`DM_FULLSCREEN=0` for nxnative ports), with Full Screen one toggle away.
  - Why: tonight the switch into full screen itself dropped focus (black and silent), while a windowed launch stays
    visible, shows the progress screen and is recoverable.
  - Not built.
  - Open questions are in the ADR: whether the port's saved launcher choice or the override wins, and whether Play
    should skip the port's own launcher window.
- ℹ️ For the record: as of 19:18 EST the renamed Retriever is the only instance running on J.R's Mac, and tonight's
  relaunch goes through its Play button. This docs-only follow-up ran no build or tests, so nothing was launched
  beside it.
- 📌 **"Keep games on top?" (J.R, 19:28 EST): answered in three layers and scoped. Nothing built.**
  - **Layer 1, no permission, buildable (ADR 0030 amendment):**
    - after a tracked Play, Retriever hides itself while the game runs and shows no sheets, alerts or notifications
      over it;
    - it restores itself without activating when the game exits;
    - the user bringing it back wins, and a grace-period timeout restores it if the game never starts;
    - on by default, with a Settings switch to turn it off;
    - design and tests are listed in the ADR.
    - Ready to build on J.R's go. Live checks wait until he isn't playing.
  - **Layer 2 — REJECTED by J.R (2026-11-08):** going blank on losing focus is normal macOS behaviour, one click
    fixes it, so don't fix what isn't broken. ADR 0032 is marked rejected and nothing will be built. Originally
    proposed (new ADR 0032) as:
    - an opt-in "keep games in front" assist using Accessibility (`kAXFrontmost` plus `AXRaise`);
    - it re-asserts only if the front is taken within about 10 s of launch, and never fights deliberate switching;
    - constraints recorded: Accessibility is heavy trust; the TCC grant is tied to the binary, so dev rebuilds
      re-prompt and it waits for stable signing; sandboxed builds can't use it; never required for basic play.
  - **Layer 3, honesty (ADR 0032 and CLAUDE.md):** macOS has no public always-on-top pin for another app's window, so
    copy never promises "stays on top".
- 📌 **ADR 0031 data point (19:21 EST):** Ollie set Ocarina's Display mode to Window in the port's settings window,
  and the game ran windowed, so the popup choice carries into the launch.
  - Read-only check at 19:30: the launcher saves only non-default choices.
  - Choosing Window removed the saved `launcher.DM_FULLSCREEN = 1`, so the domain is now absent and the log shows
    `DM_FULLSCREEN=0`, not "(changed)".
  - J.R's Ocarina is on Window.
- 📌 **QA rule (polish log):** a QA run that reaches a working game leaves it running for J.R and doesn't quit it as
  cleanup. J.R was watching the Ocarina title screen when tonight's diagnostic run closed it.
- ✅🧪 426 tests (+7); lint clean.

## 33 · feature/jump-back-in — overnight feature F1 (J.R keeps or reverts)
- ✅🧪 **"Jump Back In" shelf (ADR 0033).**
  - **Content:** at the top of All Games, games marked Playing or with a recorded session in the last 30 days, most
    recent session first.
  - **Card:** a quiet "last played" subtitle, plus the time played from the largest real source, labelled. Sources
    are never merged, and there are no HLTB figures.
  - **Visibility:** hidden while searching, on other sections, and when empty.
  - **Data:** computed only. No stored data, no settings.
- ✅🧪 Tests:
  - who qualifies: Playing, a 5-day-old session and yesterday's session are in; a 40-day-old session and never played
    are out;
  - order, including idle Playing games last;
  - the hidden-when-empty rule;
  - the line keeps the largest source with its label (10h SteamSynced beats 2h MacTracked, never 12h);
  - relative days, including future clock skew;
  - shown on All Games only and not while searching;
  - renders at 900, 1100 and 1280.
  432 tests (+6); lint clean.
- ✅ **Renders inspected** (`docs/design/jump-back-in/`). The first render cut off the single line, so the shelf now
  uses the card's two-line form.
- ⚠️ No live run against J.R's library (no Play clicks, per the brief).
- ✅🧪 **Completed games rule (J.R ruling, Mon 2026-11-09 09:36):** the shelf is games whose status is Playing, or
  played within 30 days **and not Completed**. A Completed game comes back only when its status is set to Playing; a
  fresh session alone never brings it back. New test: `aCompletedGameLeavesTheShelfUntilItIsPlayingAgain`. 433 tests.

## 34 · feature/launch-handoff — ADR 0030 Layer 1, minimal (approved by J.R)
- ✅🧪 **Retriever gets out of the game's way.**
  - After Play opens a tracked `.app`, Retriever hides itself while the game runs.
  - It restores itself without taking focus when the last process of that app exits. A port's launcher and its game
    host are both counted.
  - It restores itself after 10 s if the game never appears.
  - The library alert and the onboarding sheet are held while a game runs.
  - Nothing else about launch changed: Steam and CrossOver launches are not covered, there is no Settings switch, and
    the launcher is untouched.
- ✅🧪 Tests:
  - hide on launch, unhide on exit;
  - waits for the last process, and ignores other apps and a path with a trailing slash;
  - grace-period restore;
  - an already-running game;
  - only tracked `.app` launches hand off (a Steam URL doesn't);
  - a failed launch doesn't hide.
  439 tests (+6); lint clean. (Was 449 before J.R removed Pick for Me and Quick Wins and this branch was restacked
  onto `feature/jump-back-in`, 2026-11-09.)
- ⚠️ Not exercised live: no Play clicks against J.R's library, per the brief. The first real check is J.R pressing
  Play.

## 35 · fix/tracker-liveness — QA Finding #7, top of the queue (J.R, Mon 2026-11-09)
- **Sequence:** J.R made the tracker fix the top priority (09:36). With it he removed Pick for Me and Quick Wins,
  fixed the Jump Back In rule, and had the stack restacked: guidance → jump-back-in → launch-handoff → this branch.
  Next come F4 Home, F5 Installed, then the Meebits energy pass.
- **ADR 0025 item 7 recorded** (what not to copy from Meebits): sub-second transitions, no surface breaks the token
  system, no dead ends.
- ✅🧪 **Cause, confirmed read-only.** I copied `default.store` to a scratch folder and queried the copy.
  - Every port Play made two overlapping sessions, one for the launcher and one for the game host (`dmhost`).
  - The host session closed when the game quit. The launcher session stayed open until Retriever itself quit, at
    18:55 Nov 7 and 09:26 this morning.
  - Full table and figures: ADR 0034.
- ✅🧪 **New sessions:**
  - one run per game, so overlapping sessions are gone;
  - once a port's game host has run, it alone ends the session, even if the launcher stays open;
  - a liveness sweep every 60 s closes an exit that sent no event, at the last time the process was seen;
  - a 12 h cap stops the session there and flags it with a note;
  - Mac sleep splits the session;
  - after a restart, counting never starts before the last stored session's end.
- ✅🧪 **Handoff uses the same rules:** Retriever comes back when the game host exits, and a 5 s liveness check means
  a missed exit can't leave it hidden.
- ✅🧪 **Stored stale sessions cleaned (J.R ruling, Mon 09:36 EST: apply the fix's rules retroactively).**
  - **Evidence:** the macOS system log (WindowServer process lifecycle) shows every launcher died within 0.2 s of its
    game host. The exits were missed by the tracker; the launchers didn't linger. Details in ADR 0034.
  - **Rule (`StaleSessionPlan`):** a MacTracked session containing another of the same game is a launcher half. Under
    the fix only the host's time counts, and that is already stored, so the row is removed. Overlap trims and the
    12 h cap matched nothing on J.R's data.
  - **Applied once at launch (`TrackedSessionRepair`)** at 09:50 EST:
    - J.R's Retriever was quit cleanly first, with no game running;
    - the store was copied to `Application Support/Playrite/Backups/store-before-tracker-repair-20261109-0949…/`;
    - every change was written to the audit log with the session's ID and original times.

  | Game | Before | After | Removed rows |
  |---|---|---|---|
  | The Legend of Zelda Ocarina of Time | 88h 20m 38s (7 sessions) | **3h 02m 18s** (4) | 06:52→18:55 Nov 7, 19:19 Nov 7→09:26 Nov 9, 22:18 Nov 7→09:26 Nov 9 |
  | Super Smash Bros. Ultimate | 35h 14m 07s (2 sessions) | **2m 54s** (1) | 22:15 Nov 7→09:26 Nov 9 |

  - **`lastPlayedAt`** for both games was Nov 9 09:26:32, Retriever's quit time. It is now their last real session:
    Ocarina Nov 7 22:22:22, Smash Nov 7 22:18:17.
  - **Verified on a copy of the store** against the backup: 125 games; no other session, game or field changed.
    These were the library's only MacTracked rows, and there are no other session sources stored.
  - **Left unproven: nothing.** Every stale row was matched by the rule and confirmed by the system log.
- 🧪 `SessionLivenessTests` (8, including a replay of Ollie's 19:19:22 / 19:20:32 Ocarina pair), 2 new watcher tests
  and 2 new handoff tests, plus `StaleSessionRepairTests` (4, replaying J.R's nine rows). 455 tests; lint clean.
- ⚠️ Not exercised live: no Play clicks against J.R's library. The first real check is J.R's next port session,
  which should come out as one session whose length matches the game.

## 36 · feature/home-page — F4 Home (J.R, rescoped 09:55)
- ✅🧪 **Home is the landing page and the first rail entry (ADR 0035).**
  - **Hero:** installed games with banner art, most recently played first. It shows a 56 pt black title, one mono
    state line and Play.
  - **Rotation:** about every 6 s with a crossfade, paused on hover, arrows and dots, and no auto-advance under
    Reduce Motion.
  - **Ambient colour:** the featured art's colour washes full-bleed behind the page (design pass item 2, folded in
    as asked).
  - **Rows:** Jump Back In, then Recently Added (the last 30 days, from `addedAt`). The Quick Wins row was dropped
    with the feature.
  - **No dead ends:** an empty library offers Add Game, and "Browse All Games" ends the page.
- ✅🧪 **`InstallState`, the shared install rule** (installed / not installed / unknown). The per-source table is in
  ADR 0035, and F5 uses it.
- **J.R's hero today:** Soul Reaver 1&2, Final Fantasy Resonance, Digimon Story Time Stranger and RollerCoaster
  Tycoon 3. The other installed ports have no banner art yet.
- 🧪 Tests:
  - `InstallStateTests` (4);
  - `HomeFeedTests` (7): hero rules, a missing banner file, no hero, caps, the Recently Added window, Jump Back In's
    Completed rule;
  - `HeroCarouselTests` (5);
  - `HomeRenderTests` at 900, 1100 and 1280.
  472 tests; lint clean.
- ✅ **Renders inspected** (`docs/design/home/`). The menu-backed Play button doesn't draw offscreen; the design pass
  replaces it.
- ⚠️ No Play clicks against J.R's library.

## 37 · feature/installed-filter — F5 Installed filter (J.R, rescoped 09:55)
- ✅🧪 **"Installed" toggle in the grid toolbar (ADR 0036).**
  - It filters the current view: All Games and every status grid, with section and search included.
  - A mono count line, also the window subtitle: "N installed · N can't tell · N not installed".
  - Unknown games sit in a flagged "Can't tell if installed" group with Show/Hide. They never vanish silently.
  - Jump Back In follows the filter.
  - Nothing to show gives a "Show All Games" way out.
- **Which sources report installed reliably:**
  - tracked `.app` and ROM: yes, checked live;
  - Steam: as of the last scan;
  - a Steam app ID with no copy, or a manual entry: no, so "can't tell".
- ⚠️ **Gap for J.R:** 99 of his 100 Steam games have no Steam app ID and no recorded install, so they land under
  "Can't tell". Linking them to Steam app IDs would close it. Only RollerCoaster Tycoon 3 has a recorded copy; all 18
  recorded port apps are present.
- 🧪 `InstalledFilterTests` (3: the split and its summary, plus the view model across sections, search and the
  shelf) and `InstalledFilterRenderTests` at 900, 1100 and 1280. 476 tests; lint clean.
- ✅ **Renders inspected** (`docs/design/installed-filter/`). The window toolbar isn't part of offscreen renders.

## 38 · feature/meebits-energy-pass — design pass at three intensities (J.R 09:41 + 09:55; not to merge without his eyeball)
- ✅ **ADR 0025 item 7 recorded** on `fix/tracker-liveness`: sub-second transitions, no surface breaks the tokens,
  no dead ends.
- ✅ **Audit** (full table in ADR 0037), state before this branch:
  - item 1, colour fields: gap;
  - item 2, ambient Home: done in F4;
  - item 3, graph paper: gap;
  - item 4, type: partial, with about ten proportional-type data stragglers;
  - item 5, accent: crept into six places, and Play was a stock button;
  - item 6, hover: a ring plus a wash, no lift;
  - item 7, detail: a 280 pt hero, and the rail repeated the art.
- ✅🧪 **Built behind a three-position dial (As specced / Leaned in / Full send, `EnergyLevel` tokens).**
  - Art-coloured tile fields, with neutral tiles when there's no art.
  - ~~Graph paper on the grid and Home~~: rejected by J.R in round 1 and removed (below).
  - Shelf headers 24 / 32 / 44 pt black; Home hero title 60 / 80 / 104.
  - All listed data stragglers in mono.
  - The accent pulled back to Play, nav, links and the wordmark, guarded by a source scan. Play has the one
    gradient.
  - Hover lifts the card and scales the art, and does nothing under Reduce Motion.
  - Detail hero 380 / 460 / 560 pt; the rail cover shows only when there's no hero art.
- **The app runs at Leaned in.** Try another position live with
  `defaults write com.studiojrba.Playrite design.intensity fullSend` (or `specced`), then relaunch.
- ✅ **Renders** in `docs/design/energy-pass/`: `before/`, then each position for Home and the grid at 900, 1100 and
  1280, plus two comparison sheets.
- 🧪 `EnergyPassTests` (5: default position, every value rises with the dial, fades under a second, the accent scan,
  no background texture) and `EnergyPassRenderTests` (6). 483 tests; lint clean.
- ⚠️ **Open for J.R:**
  - the dial position;
  - whether "electric indigo" means switching from our Fetch orange (a two-colour palette change);
  - moving playtime and sessions into the detail rail (item 7's remaining gap).
- ✅🧪 **Design feedback round 1 (J.R, Mon 13:31 EST):** "I like the direction for sure but I don't like that grid
  background."
  - The graph-paper texture is **tried and rejected**. Removed at every dial position: `GraphPaperBackground`, its
    two `EnergyLevel` values, and its uses on the grid and Home. Both are back on the flat canvas.
  - Recorded in ADR 0037 under "Tried and rejected" so it doesn't return in a later pass, in any pattern.
    `EnergyPassTests.noBackgroundTextureComesBack` guards the source.
  - Everything else in the pass is unchanged. The renders predate this and still show the grid.

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
| 13 | `feature/steam-signin` | ✅ | ✅ | 256 | ✅ |
| 14 | `feature/bottle-automation` | ✅ | ✅ | 283 | ✅ |
| 15 | `feature/onboarding` | ✅ | ✅ | 291 | ✅ |
| 16 | `feature/emulator-launch` | ✅ | ✅ | 304 | ✅ |
| 17 | `feature/component-updates` | ✅ | ✅ | 319 | ✅ |
| 18 | `feature/steam-signin-loopback` (QA #1) | ✅ | ✅ | 327 | ✅ |
| 19 | `feature/nxnative-file-prompts` | ✅ | ✅ | 333 | ✅ |
| 20 | `feature/mit-license` | ✅ | ✅ | 333 | ✅ |
| 21 | `feature/detail-layout-fit` (QA #2) | ✅ | ✅ | 336 | ✅ |
| 22 | `feature/hltb-cache-read` (QA #3) | ✅ | ✅ | 342 | ✅ |
| 23 | `feature/nxnative-on-by-default` (J.R correction) | ✅ | ✅ | 357 | ✅ |
| 24 | `feature/nxnative-derived-invocation` (Phase 1 blocker) | ✅ | ✅ | 373 | ✅ |
| 25 | `feature/folder-first-add-build` (J.R requirement) | ✅ | ✅ | 391 | ✅ |
| 26 | `feature/builds-inbox` (superseded by 28) | ✅ | ✅ | 402 | ✅ |
| 27 | `feature/ui-polish` (design phase) | ✅ | ✅ | 409 | ✅ |
| 28 | `fix/remove-downloads-watcher` (launch hang; J.R reversal) | ✅ | ✅ | 399 | ✅ |
| 29 | `fix/standalone-nxnative-only` (J.R rule) | ✅ | ✅ | 401 | ✅ |
| 30 | `feature/builds-detail-showcase` (J.R direction) | ✅ | ✅ | 415 | ✅ |
| 31 | `feature/app-rename-retriever` (J.R GO) | ✅ | ✅ | 419 | ✅ |
| 32 | `feature/nxnative-first-launch-guidance` (Finding #6 follow-ups) | ✅ | ✅ | 426 | ✅ |
| 33 | `feature/jump-back-in` (F1, Completed rule fixed) | ✅ | ✅ | 433 | ✅ |
| 34 | `feature/launch-handoff` (Layer 1 minimal) | ✅ | ✅ | 439 | ✅ |
| 35 | `fix/tracker-liveness` (Finding #7, stored data cleaned) | ✅ | ✅ | 455 | ✅ |
| 36 | `feature/home-page` (F4) | ✅ | ✅ | 472 | ✅ |
| 37 | `feature/installed-filter` (F5) | ✅ | ✅ | 476 | ✅ |
| 38 | `feature/meebits-energy-pass` (look; J.R's eyeball first) | ✅ | ✅ | 483 | ✅ |

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

## Key decisions (see `docs/decisions/` ADR 0001–0037)
- Empty upstream repo, so the feature branches are **stacked**. The default branch is `production`; there is no `main`.
- XcodeGen (`project.yml`). The `.xcodeproj` is git-ignored; generate it with `./scripts/bootstrap.sh`.
- One app module with strict feature folders. Every service is protocol-first, with a mock for previews and tests.
- Views are driven entirely by design tokens and built from small components, ready for a Figma re-skin
  (enforced by a SwiftLint custom rule plus a manual audit).
- Playtime is stored per source and never merged; badges use real data only; HLTB is always labelled
  "HLTB estimate".
- The Steam key lives only in the Keychain. NXNative is on by default and detects the user's engine and keys
  (ADR 0021); it never bundles anything and cannot delete files (it has no delete API, and a policy test checks this).
- No scraping anywhere: GameFAQs guides are link-out only, and HLTB uses manual entry plus a link-out because
  there is no official API.

## Stubbed / not verified automatically
- Live Steam calls and the real Keychain wrapper. No key was available; both are covered with mocks.
- The live NSWorkspace observer and `ProcessBuildEngineRunner` against a real engine. No engine was available;
  both are covered with mocks and checked with a build and a launch.
- The nxnative CLI contract is now known for nxnative checkouts (ADR 0022), and a detected checkout's invocation
  is derived. Other engines keep the configurable template. Title metadata is entered manually (optional title ID
  for Switch 2), and the troubleshooting patch is an editable template.
- Automatic HLTB lookup is intentionally not implemented. The `HLTBRemoteSearching` seam is ready.
- A live Nintendo eShop metadata source (ADR 0014), extra providers, and the Figma visual pass are future work.

## Next steps
1. Open PRs into `production` in order 0 → 38 (`production` is the default branch; there is no `main`).
2. **GitHub Actions CI** (`feature/ci`, planned in `docs/PLAN.md`): run lint, build and test on pull requests,
   on a macOS runner.
3. Manually smoke-test the Steam flow with a real key, and the NXNative flow with the real engine.
4. Re-skin from Figma by changing tokens and components only.
