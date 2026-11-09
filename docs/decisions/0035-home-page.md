# ADR 0035 — Home: the landing page

- Status: accepted (J.R, F4, Mon 2026-11-09 09:28 EST; rescoped 09:55 after Quick Wins was deleted)
- Branch: `feature/home-page`
- Related: ADR 0033 (Jump Back In), ADR 0025 (design rules, item 7), ADR 0016 (zero-tinker)

## Decision
- **Navigation:** "Home" is the first rail entry and the page Retriever opens on. All Games is unchanged.
- **Hero:** installed games that have banner art (`heroImagePath`, the existing artwork pipeline), most recently
  played first, up to 8.
  - Each shows the art full width, the title in heavy display type (56 pt black rounded), one quiet state line in
    mono (the Jump Back In line: last played and time played from the largest real source, labelled), and the standard
    Play button.
  - Rotation (`HeroCarousel`):
    - advances about every 6 s with a 0.7 s crossfade;
    - pauses while the pointer is over the hero;
    - after the user uses the arrows or dots, waits a full interval before advancing again;
    - under Reduce Motion it never auto-advances and switches without a fade.
  - No qualifying game means no hero and no empty box.
- **Ambient colour (folded in from the design pass, item 2):** the featured game's art colour washes full-bleed into
  the page behind the hero (`HomeAmbientBackground`), fading out down the page and crossfading with the hero.
  - The chrome stays monochrome: the colour comes from the art.
  - Strength is set by tokens in `DesignTokens.Home`, so the design pass can dial it up or down.
- **Rows:** the Jump Back In shelf (its own rules, ADR 0033), then Recently Added (games added in the last 30 days,
  newest first, up to 12). Recently Added comes free from `addedAt`. Each row hides when empty.
  - The Quick Wins preview row was dropped with the feature (J.R, 09:55), and nothing replaces it.
- **No dead ends (ADR 0025 item 7):**
  - an empty library shows "Your library is empty" with Add Game;
  - otherwise a "Browse All Games" button always ends the page.

## Installed — one shared rule (`InstallState`)
| Source | Installed when | Reliable? |
|---|---|---|
| Tracked `.app` (Mac games, built ports, emulator apps) | the bundle exists on disk | yes, checked live |
| ROM (emulated games) | the ROM file exists | yes, checked live |
| Steam | a copy was found in a detected Steam library folder at the last scan | as of the last scan |

- A recorded `.app` or ROM path that's gone is **not installed**.
- A game with none of these is **unknown**. That includes a Steam game with an app ID but no copy found, because
  Retriever can't tell "not installed" from "never scanned". It never guesses.
- F5's Installed filter uses the same rule.

## Consequences
- **J.R's library (checked read-only):** four games qualify for the hero today:
  - Legacy of Kain: Soul Reaver 1&2 Remastered, Final Fantasy Resonance and Digimon Story Time Stranger (built ports,
    app present, banner art);
  - RollerCoaster Tycoon 3: Platinum! (Steam copy recorded, banner art).
  - The other installed ports have no banner art yet, so they don't appear in the hero. Fetching art adds them
    automatically.
- **Performance:** the feed is computed from the in-memory library (125 file checks per refresh, negligible), and
  only the showing banner is decoded.
- **Render note:** the offscreen renderer can't draw AppKit's menu-backed Play button, so it looks faint in
  `docs/design/home/`. The design pass replaces Play with a custom gradient surface.
- Not exercised live with Play, per the brief.
