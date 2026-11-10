# ADR 0046 — NX Shelf 1.0: Switch + emulators only; Steam and CrossOver removed; no sign-in anywhere

**Status:** Accepted · 2026-11-09 (J.R, Mon 21:29 EST, corrected 22:48 EST)

## Context
J.R narrowed 1.0 to what NX Shelf does better than anything else on his Mac:
- adopt the Switch ports and ROMs already on disk, without rebuilding them (the thing NX Play would not do);
- build native Switch ports on standalone nxnative;
- route emulated games to the emulator that owns them.

His correction made two things total:
- **Steam is removed, not parked.** That includes the integration, the sign-in, every Steam-sourced code path, and
  his old Steam library data, which the fresh identity (ADR 0045) no longer reads.
- **1.0 has no sign-in anywhere.** The only account-shaped features are API keys the user pastes.

## Decision
- **What 1.0 is:**
  1. **A shelf that launches games.** First run and every rescan adopt existing standalone nxnative `.app`
     builds and ROM folders, with zero rebuilding (below).
  2. **Native Switch building** on standalone nxnative (ADR 0027), unchanged: the one big tool inside.
  3. **An emulator hub.** It detects the emulators the user installed (RetroArch and others; ADR 0019), maps ROMs
     to systems, and launches each through the owning emulator.
- **Keys, BIOS and ROMs** stay user-provided, always. Nothing that runs games is bundled.
- **Removed completely (code deleted):**
  - **Steam:**
    - the Web API client, sync and owned-games import, and recently played;
    - Steam achievements and the badge built on them;
    - OpenID sign-in, including the loopback server and browser flow;
    - API key handling;
    - Steam settings, the dashboard and its sidebar item;
    - install scanning;
    - the store `appdetails` metadata provider and Steam trailers;
    - Steam app-state update badges;
    - the `steam://` launch route;
    - Steam fields on `Game` (`steamAppID`, `steamSyncedSeconds`, achievements, installs), the `steamSynced`
      playtime source and the `.steam` platform.
  - **CrossOver:**
    - golden bottles and per-game bottles;
    - recipes and the installer;
    - bottle scanning and launcher import;
    - the CrossOver launch route;
    - its onboarding module.
  - **The never-connected Nintendo eShop search seam**, replaced by titledb (ADR 0038).
  - The shared process runner (`CommandRunning`) moved to `Shared/Utilities`, because the component installer
    still uses it.
- **Adoption (the headline fix):**
  - `AppBundleScanner` reads the Switch title ID that nxnative stamps into every build's bundle identifier
    (`org.nxnative.<id>`).
  - A bundle with a stamped title ID, a port library beside it, or a home in the Switch games folder imports as a
    Switch port. This works wherever it sits in a scanned folder, and the title ID is stored on the game, so
    titledb media and update badges work at once.
  - A rescan adopts the stamped ID for a game it already knows. It never overwrites an ID recorded by a build
    through NX Shelf.
  - ROM files become emulated games with their system. `~/Switch/Games` is scanned even when nothing is
    configured.
  - Re-scans add nothing.
- **Metadata sources:**
  - titledb (keyless, official eShop data, Switch ports);
  - IGDB (pasted Twitch client ID + secret);
  - SteamGridDB (pasted key, art fallback).

  Every key read happens off the main thread (ADR 0044).
- **No sign-in:** the account-shaped features are pasted API keys in the Keychain (`com.studiojrba.NXShelf`):
  - SteamGridDB;
  - IGDB;
  - RetroAchievements (username + web API key, ADR 0047).

  There is no OAuth, no login window and no identity phoning home.

## Consequences
- **Library files:** archives exported by earlier builds that contain Steam games no longer import those entries
  (their platform no longer exists). The fresh start doesn't import old data anyway.
- **One less source for stats:** stats and badges count only Mac-tracked and self-reported play.
- **Bringing Steam or CrossOver back** would be a new feature built on the current model. The old code remains in
  git history and on the retained branches.
