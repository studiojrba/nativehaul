# ADR 0036 — The Installed filter

- Status: accepted (J.R, F5, Mon 2026-11-09 09:28 EST; rescoped 09:55: All Games and every grid view, with Quick Wins
  dropped)
- Branch: `feature/installed-filter`
- Related: ADR 0035 (`InstallState`, the shared install rule)

## Decision
- **Control:** an "Installed" toggle (`internaldrive`) in the library grid's own toolbar. It appears on All Games and
  on every status grid (Playing, Backlog, Completed), and nowhere else.
  - It filters the current view, section and search included.
  - The filter is part of `LibraryFilter`, so it stays on while you move between grid sections.
- **Truth per source:** the `InstallState` rule from ADR 0035.

| Source | Reports installed reliably? | How |
|---|---|---|
| Tracked `.app` (Mac games, built ports, emulator apps) | **yes** | the bundle exists on disk, checked live |
| ROM (emulated games) | **yes** | the ROM file exists, checked live |
| Steam | **as of the last scan** | a copy was found in a detected Steam library folder (Mac Steam or a CrossOver bottle). Retriever rescans at launch. |
| Steam app ID with no copy found | **no**, so unknown | Retriever can't tell "not installed" from "never scanned" |
| Manually added, nothing recorded | **no**, so unknown | nothing to check |

- **Unknown never vanishes silently.** With the filter on, the view shows:
  - the installed games;
  - a mono count line, e.g. "18 installed · 99 can't tell · 1 not installed", also used as the window subtitle;
  - a "Can't tell if installed" group with a Show/Hide button.
  - Games whose recorded install is gone are counted as "not installed" and left out.
- **Jump Back In** follows the filter: only installed shelf games show while it's on.
- **No dead end:** if nothing in the view is installed or unknown, the page says so with the count and a "Show All
  Games" button that turns the filter off.

## The gap, for J.R
- In J.R's library (checked read-only), **99 of the 100 Steam games have no Steam app ID and no recorded install**, so
  the filter can only put them under "Can't tell".
- Only RollerCoaster Tycoon 3 has a recorded Steam copy.
- All 18 recorded port apps are present.
- Closing the gap needs those games linked to their Steam app IDs, for example by Steam sign-in and sync, or a Steam
  library scan that matches them by title. Then the Steam rows can report installed or not.
- The filter doesn't guess in the meantime.

## Consequences
- Each grid refresh checks the disk once per game in the view (125 checks at most), which is negligible.
- Offscreen renders show the filtered grid but not the window toolbar, so the toggle itself isn't in
  `docs/design/installed-filter/`.
