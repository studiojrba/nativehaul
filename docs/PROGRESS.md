# Playrite — Progress Log

Living status log. Each branch appends its section. Legend: ✅ built & compiles · 🧪 unit-tested · 🟡 stubbed · ⛔ blocked.

## Session decisions (overnight build, 2026-11-06)
- **Empty upstream repo**: `origin/main` had no commits. Since nothing may be committed to `main`, feature
  branches are **stacked** — each branches from the previous feature branch's tip. Merge in order 0 → 7.
- **Tooling**: installed `xcodegen`, `swiftformat`, `swiftlint` via Homebrew. Project generated from `project.yml`;
  `Playrite.xcodeproj` is git-ignored. Run `./scripts/bootstrap.sh` then open `Playrite.xcodeproj`.
- **Toolchain observed**: Xcode 27.2, Swift 6.4.2, macOS 26.6 host; deployment target macOS 15.0, arm64 only.
- **Targets**: single app target `Playrite` with strict feature folders (ADR 0005) + `PlayriteTests` (Swift Testing, app-hosted).
- **Push blocked**: `gh` active account `jr-resilia` gets 403 on `studiojrba/Playrite`; see `BLOCKED.md`. All branches are committed locally and must be pushed in the morning (one-liner in BLOCKED.md).
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

## Status by branch (stacked, merge in this order)
| # | Branch | Built | Compiles | Tests | Pushed |
|---|--------|-------|----------|-------|--------|
| 0 | `feature/project-foundation` | ✅ | ✅ | 1 | ⛔ |
| 1 | `feature/library-core` | ✅ | ✅ | 22 | ⛔ |
| 2 | `feature/steam-provider` | ✅ | ✅ | 47 | ⛔ |
| 3 | `feature/playtime-tracking` | ✅ | ✅ | 63 | ⛔ |
| 4 | `feature/series-collections` | ✅ | ✅ | 79 | ⛔ |
| 5 | `feature/stats-badges` | ✅ | ✅ | 92 | ⛔ |
| 6 | `feature/nxnative-module` | ✅ | ✅ | 123 | ⛔ |
| 7 | `feature/guides-hltb` | ✅ | ✅ | 142 | ⛔ |

Test counts are cumulative. On every branch, `./scripts/build.sh` gives BUILD SUCCEEDED and TEST SUCCEEDED,
`swiftlint lint --strict` reports 0 violations, and SwiftFormat is clean. The app was launch-checked on branches
1, 3 and 7.

## ⛔ The one blocker: pushing
`git push` returns **403**: the active `gh` account `jr-resilia` has no write access to `studiojrba/Playrite`.
Claude was not allowed to use the inactive `studiojrba` account's credentials, so no workaround was tried.
**Everything is committed locally.** To unblock, follow `BLOCKED.md`: switch the gh account, then push every
`feature/*` branch.

## Key decisions (see `docs/decisions/` ADR 0001–0009)
- Empty upstream repo, so the feature branches are **stacked**. `main` was never touched.
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
- Cover art fetching, extra providers, and the Figma visual pass are future work (`docs/PLAN.md`).

## Next steps
1. Unblock the push (`BLOCKED.md`), then open PRs in order 0 → 7.
2. **GitHub Actions CI** (`feature/ci`, planned in `docs/PLAN.md`): run lint, build and test on pull requests,
   on a macOS runner.
3. Manually smoke-test the Steam flow with a real key, and the NXNative flow with the real engine.
4. Re-skin from Figma by changing tokens and components only.
