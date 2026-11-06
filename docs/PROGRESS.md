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

## Key decisions (see `docs/decisions/` ADR 0001–0020)
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
1. Open PRs into `production` in order 0 → 22 (`production` is the default branch; there is no `main`).
2. **GitHub Actions CI** (`feature/ci`, planned in `docs/PLAN.md`): run lint, build and test on pull requests,
   on a macOS runner.
3. Manually smoke-test the Steam flow with a real key, and the NXNative flow with the real engine.
4. Re-skin from Figma by changing tokens and components only.
