# ADR 0026 — No watched folders: access follows the user's pick

**Status:** Accepted · 2026-11-07 · J.R decision (00:28 EST) · supersedes ADR 0024

## Context
ADR 0024 watched `~/Downloads` from first run so new game files could be queued without a picker.

- Downloads is a **macOS-protected folder**. Reading it programmatically triggers the system's privacy prompt, and
  Debug rebuilds (new signature) trigger it again.
- The watcher opened the folder on the main thread at launch. Tonight that wait kept the app's window from ever
  appearing:
  - the process stayed alive with a 0×0, never-shown window;
  - there was no crash report;
  - every relaunch just re-activated the stuck instance.
  This blocked Phase 1's Ocarina test.

## Decision
J.R: **scratch the Downloads watcher entirely.** He does not want Retriever watching a protected folder
programmatically.

- **Removed:**
  - the folder watcher (live and mock);
  - the default Downloads watching;
  - the Builds inbox section, its view model, its scanner, its dismissals store and the built-title check;
  - the inbox fields in `EngineConfiguration` (older saved settings still decode; the keys are ignored);
  - the Settings → NXNative "Builds inbox" controls;
  - the Downloads purpose string.
  Onboarding's trust line is back to its original, literally true wording: "It only looks in folders you point it
  at, plus the standard places games install to (Steam, CrossOver, ~/Switch/Games)."
- **Kept:**
  - Folder-first Add Build (ADR 0023): the user picks the folder, and **the pick is the permission**.
  - The scanner and grouping that serve it, including skipping unfinished downloads.
  - The Add Build pickers opening in Downloads. A user-invoked pick is consent; the watcher was the problem, not the
    picker.
- **Rule:**
  - Retriever never opens a protected folder (Downloads, Desktop, Documents and the like) by itself.
  - Access follows the user's pick.
  - Retriever never asks for **Full Disk Access**.
  - Nothing at launch reads a protected folder. Engine and key detection (ADR 0021) only looks in unprotected tool
    locations.

## Consequences
- The launch hang is gone with the watcher: nothing on the launch path can wait on a privacy prompt.
- Unattended queueing (J.R's overnight-runs motivation) needs another route that respects this rule, for example a
  folder the user picks once in Add Build or Settings. Nothing is planned yet.
- Kept from the inbox branch, because it is useful on its own: the unit-test host starts nothing live, so tests
  never touch the user's library or folders.
