# ADR 0024 — Builds inbox: a watched folder, no picker in the path

**Status:** Accepted · 2026-11-07 · J.R feature

## Context
File pickers are the one flow that can't run unattended. J.R wants builds startable without anyone at the Mac (for
example, queued before an overnight run). For everyone else it's zero-tinker (ADR 0016, ADR 0021): download a game,
and it's simply there, ready to build.

## Decision
- **One watched folder, on by default:** `~/Downloads`, from first run, with no picker and no setup step.
  `EngineConfiguration.inboxFolder` overrides the folder (`nil` means Downloads), and `isInboxSwitchedOffByUser`
  records an explicit off. Settings → NXNative → **Builds inbox** has the toggle, **Choose…** and **Use
  Downloads**. Settings saved before this change decode as watching Downloads.
- **Detection** (`BuildsInboxScanner`, read-only) runs at launch, when the folder changes (`DispatchFolderWatcher`:
  a kernel event source on the folder, debounced 2 s), when the Builds page appears, and on **Refresh**.
  - **Inputs:**
    - package files loose in the folder, grouped by title ID exactly as a folder pick (the engine gets the folder,
      plus `--title-id` when it holds more than one game);
    - `.nup` files loose in the folder;
    - each subfolder that `GameFolderScanner` can build (a mixed folder of packages, or a Switch 2 dump).
  - Every item carries the folder-first summary (ADR 0023): name, title ID, "Base game · update vN · N DLC" or the
    Switch 2 line.
  - **Ignored:**
    - archives (`.zip`, `.rar`, …): not inputs, never extracted;
    - unfinished downloads: an in-progress extension (`.crdownload`, `.part`, `.partial`, `.download`,
      `.opdownload`, `.aria2`, `.tmp`) or a sidecar with one beside the file;
    - hidden items, `.app` bundles, and anything that can't be built (an update without its base, a folder of
      documents). These are simply not offered.
- **UI:** a section at the top of the Builds queue, titled after the folder ("New in Downloads"), with one plain line:
  "Retriever watches Downloads for new game files to build. You can change the folder or turn this off in
  Settings → NXNative." Each item has **Queue** and **Dismiss**. Queue enqueues through the same path as Add Build,
  so the derived invocation (ADR 0022) runs when it builds. There is **no picker in this path**, and **nothing
  auto-builds**: queueing is always a click.
- **Dedupe:** an item is hidden when it is
  - already a job in the queue (same source, same title ID);
  - already a built Switch app in the library (same title ID, or the same name when there is no ID);
  - dismissed. Dismissals persist (`UserDefaultsBuildsInboxDismissals`).
- **Being honest about what Retriever looks at:**
  - The onboarding trust line now lists everything Retriever looks in: folders you point it at; the standard game
    install places; the usual places for your own nxnative engine and prod.keys (ADR 0021, which the old line
    missed); and Downloads for new Switch game files, which can be changed or turned off.
  - macOS protects Downloads, so the first look shows the system's one-time permission prompt. The app now gives
    it a plain purpose string (`NSDownloadsFolderUsageDescription`).
- **Test isolation fix found along the way:** the unit-test host used to launch the full live app, with J.R's
  library, upkeep and now his Downloads. Watching Downloads made the runner hang on that permission prompt. The app
  now starts nothing live when it is only hosting tests.

## Consequences
- Download → the game appears on the Builds page → one click to queue, and a later queue run builds it unattended.
- Detection works from names and package headers. A file whose download tool uses none of the in-progress
  conventions could be listed before it finishes; the engine then fails it in preflight or at build. Nothing builds
  without a click either way.
