# ADR 0012 — Steam provenance (Mac vs CrossOver) and launch routing

**Status:** Accepted · 2026-11-06

## Context
A Steam game can be installed in native Mac Steam, in a Windows Steam inside a CrossOver bottle, or both. The two
need different launches. Folder import deliberately skips bottle `Steam` folders (ADR 0010), so those games were
invisible.

## Decision
- **Detection (`SteamInstallScanner`):**
  - Read `appmanifest_<id>.acf` files from Mac Steam's `steamapps` and every library in its `libraryfolders.vdf`.
  - Do the same for each bottle's `drive_c/Program Files (x86)/Steam` and `Program Files/Steam`. Windows library
    paths are resolved through `drive_c` or `dosdevices/<letter>:`.
  - A flat KeyValues reader is enough; no VDF dependency. Steam runtimes and redistributables are ignored.
- **Recording:**
  - Each game carries `steamInstalls: [SteamInstallLocation]` (Mac and/or a bottle) and `installSizeBytes`.
  - Provenance is recomputed on every "Scan Game Folders", so uninstalled copies disappear.
  - Games are matched by app ID, then by normalised title among entries without one; unknown installed games are
    added as Steam backlog entries.
- **Launch routing (`LaunchPlanner` → `GameLaunching`):**
  - The tracked `.app` comes first and opens through NSWorkspace, so the playtime watcher records the session.
  - Steam (Mac) uses `steam://rungameid/<id>`.
  - Steam (CrossOver — bottle) runs CrossOver's `wine --bottle <bottle> --cx-app "C:\…\steam.exe" -applaunch <id>`.
  - An app ID with no detected install falls back to Mac Steam. No target means launching is disabled with the reason.
- Provenance is machine-local, so it is not exported in the library archive.

## Consequences
- One entry per game, with both Steam locations shown ("Steam (Mac)", "Steam (CrossOver — <bottle>)").
- The CrossOver command line is unverified against a live install. It lives in `CrossOverLaunchConfiguration` and can
  be adjusted in one place.
