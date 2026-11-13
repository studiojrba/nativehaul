# ADR 0055 — The 0.1.0 desktop shell, Home and Library

**Status:** Accepted · 2026-11-13 (0.1.0 overnight run, Phase 2; spec `nativehaul-swift-spec.md` §3.0–§3.2, §4.1–§4.3,
§6). Copy marked *pending* awaits J.R's approval.

## Context
0.1.0 replaces the floating icon rail and the Playnite-style grid with the Make design: a floating nav island, a
three-pill top bar, a hero carousel of Jump Back In games, full-bleed shelves and a cover grid. The Make code runs on
mock data (hand-written hero lines, curated shelf lists, a fake launch timer); the app must run on the real library.

## Decision
- **Shell** (`Features/Shell`): `ShellViewModel` owns the screen (`AppScreen`: home, library, detail, builds,
  settings), Detail's origin, search, the launch overlay and the mode (`AppMode`; couch is a documented no-op until its
  phase). `AppShellView` floats `NavIsland` and `TopBar` over the page under a hidden, transparent title bar. Each
  screen is its own page, so navigating starts at the top.
- **Window buttons**: the design's three decorative dots are *not* drawn next to the real ones. The left pill reserves
  their space and `WindowChromeView` moves the real close/minimise/zoom buttons into it (titlebar container resized,
  re-applied on resize, key and full-screen changes — the approach Electron uses for `trafficLightPosition`). If AppKit
  ever refuses, the buttons stay where macOS puts them and the pill's slot is empty.
- **Launch overlay**: shown on Play; dismissed when the game takes over (nativehaul resigns active, or the handoff hides
  it) or the launch fails (error to the main window's alert). Never on a timer; Esc or a click dismisses it as a safety
  valve. A game with no launch route opens its Detail (which explains why) instead of flashing the overlay.
- **Menu bar keeps what the island drops**: File → Add Game (⌘N); Library menu (Import/Export, Scan Game Folders,
  Configure Game Folders, Merge Duplicates, Fetch Missing Metadata, Show section filter, Installed Only); Go menu
  (⌘1–⌘4 screens, ⌘[ Back, ⌘K Find a Game, ⌥⌘1–⌥⌘4 Series, Collections, Stats & Badges, Playtime Tracking). The tools
  open as sheets, not windows: nativehaul never brings windows forward by itself (ADR 0030 rule test).
- **Home** from real data: hero = Jump Back In (§1.10, unchanged rule), at most 8 slides; copy from `HeroCopyWriter`
  templates over last played, biggest-source playtime and the last session — never invented story. If Jump Back In is
  empty, one calm fallback slide (latest played, else newest added: "There's always *{short}*."). Continue playing =
  ranks 2–4. Curated shelves are hidden (no real tag source; membership is never faked). Whole-shelf card sums each
  game's biggest single source.
- **Library**: sort in `LibrarySort` (A–Z ignores a leading "The "; Most played = biggest single source); badges only
  from a real build job for the title or a known newer version; the menu bar's filters show as a clearable chip.
- **Shelves**: `ShelfScroller` = SwiftUI `ScrollView` + `ScrollPosition`, driven by `ShelfGlideController`; maths in
  `ShelfPhysics` (tested). Shadow room is padding inside the scrollport.
- **Hero case choreography** is evaluated as pure functions of time (`CaseChoreography`, CSS per-interval bezier),
  rendered with a `TimelineView` that runs only while a switch is in flight.

## Consequences
- Detail, Builds and Settings show the pre-0.1.0 screens inside the new shell until Phases 3–4 replace them; the Builds
  toolbar moved into an in-page action bar because the title bar is hidden.
- The old rail, `HomeFeed`, the Jump Back In shelf line helpers and the energy-dial Home are gone.
- Convenience wins (ADR 0016): everything works on defaults; filters and tools are one menu away, never a setup step.
