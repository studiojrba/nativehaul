# ADR 0044 — Crash pass: the "instability" was the window freezing on Keychain reads

**Status:** Accepted · 2026-11-09 (J.R, Mon 21:29 EST: "feels unstable, keeps crashing"; stability before features)

## What was found
I mined `~/Library/Logs/DiagnosticReports` (and the system-level folder) for every report from this app under
all three names (Playrite, Retriever, nativehaul), and sampled the live app. Ranked by impact on J.R:

| # | Signature | Reports | Real use or tests? | Status |
|---|-----------|---------|--------------------|--------|
| 1 | **Window frozen on a Keychain read at launch.** `RootView` launch task → `LibraryViewModel.runAutomaticUpkeep` → `SteamSyncService.isConfigured` → `SteamAccountStore.hasAPIKey` → `SecItemCopyMatching` on the **main thread**, waiting on a macOS Keychain permission prompt. Seen live tonight in both the old Retriever and the new nativehaul copies: frozen for the whole session until the prompt is answered. | live sample ×2 | Real use | **Fixed** (below) |
| 2 | **Launch hang (2026-11-07 00:24, `.hang`).** Main thread inside `NXNativeViewModel.init` → `NXNativeLocator.keysSearchPaths`. | 1 | Real use | Already fixed by `11daf02` nine minutes later (the Downloads watcher that hung launch was removed); the remaining search is a quick `~/Switch` listing |
| 3 | **CPU overuse (2026-11-09 20:32, 20:41, 20:54, `cpu_resource`).** The v2 light build: the game case scene's 60 fps sway (`GameCaseScene`) and timelines. | 3 | Real use | Gone with the v2 revert (ADR 0042) |
| 4 | **CPU overuse (2026-11-06 13:37).** `SteamBottleClient.installProgress` polling loop during a CrossOver Steam install. | 1 | Real use | Leaves with CrossOver in the 1.0 scope surgery |
| 5 | **Crash (2026-11-06 14:13, `EXC_BREAKPOINT`).** `WebAuthenticationSessionRunner.authenticate`, the old Steam web sign-in. | 1 | Real use | That runner was replaced by loopback sign-in (QA #1); Steam leaves 1.0 |
| 6 | **Test-host crashes (2026-11-08 ×3, 2026-11-09 ×5, `EXC_BREAKPOINT`).** SwiftData "model instance destroyed by `ModelContext.reset`": the test host (a copy of the app) running `PickForMeTests`, `TitleDBMediaFetchTests` and `DetailRedesignRenderTests` with fixtures whose context went away. | 8 | **Tests only**, never J.R | Fixed in those tests at the time (or reverted with v2); the suite is green |

The only crash from real use is #5, from three days ago, in code that no longer exists. J.R's "keeps crashing"
matches #1: the window stops responding at launch, which reads as a crash.

## Decision
- **Fix 1: no Keychain read on the main thread at launch.**
  - Launch upkeep now asks `SteamSyncing.isConfiguredOffMain()`, and `SteamAccountStore.credentials()` is async;
    both read the Keychain in a detached task.
  - Even with a permission prompt pending, the window keeps working.
  - Regression test: `LaunchNeverBlocksOnKeychainTests` runs upkeep against a secret store that records the
    thread of every read, and requires zero main-thread reads.
- **Fix 2: a stable signature, so the prompt stops coming back.**
  - The prompt appears because ad-hoc signing gives every build a new identity, which the Keychain's access list
    no longer recognises.
  - `scripts/build.sh` now re-signs the canonical app with the Mac's Apple Development certificate when there is
    one (no team ID or personal identifier is written into the repo).
  - After one last "Always Allow", rebuilds keep access. Release builds are signed with Developer ID (release
    track).

## Consequences
- **One more prompt:** J.R will see one more Keychain prompt for the newly signed build. Choosing Always Allow
  ends them for future builds.
- **Steam's other Keychain reads:** Steam's remaining reads happen in its settings UI, which leaves 1.0 in the
  scope surgery.
