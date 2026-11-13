# ADR 0058 — Couch mode for 0.1.0: the mirror

**Status:** Accepted · 2026-11-13 (0.1.0 overnight run, Phase 5; spec `nativehaul-swift-spec.md` §3.7, §4.1, §4.2,
§2; TV plan Q1–Q3, Q5, Q7, Q9; Nov 12 summary §2, §4 "Couch correction"). Amends ADR 0052 and, for couch only,
ADR 0030. The 10-foot layouts of Library, Detail, Builds, Settings and the nav column are undesigned: they need
J.R's eyes.

## Context
The Make export's couch is the earlier stripped shell (hero, three shelves, a mock "playing" screen). The settled
rule (Nov 12) is that couch **mirrors the desktop** with controller navigation worked in. The M1 TV shell
(`feature/tv-mode-shell`, ADR 0052) had a working input layer and full-screen launch but its own standalone screens.

## Decision
- **Where couch lives:** the main window. The top bar's Couch mode pill, Go ▸ Couch Mode (⇧⌘F) or the saved
  "Open in: Couch" (at launch, and when onboarding finishes with that pick — onboarding itself always runs at the
  desk) set `ShellViewModel.mode = .couch`; `RootView` then shows `CouchRootView` instead of the desktop shell, and
  `CouchFullScreenWindow` takes the window full screen and hands it back on exit. The desktop's own state (screen,
  Detail, search) is kept. Alerts wait for the desktop (a controller can't dismiss them).
- **Mirror, not a second app:** couch reuses the desktop's view models — `HomeViewModel` (and its `HeroCarousel`,
  shared), `LibraryViewModel`, `BuildsViewModel`, `DetailViewModel`, `AudioController`, `AppearanceController`,
  `ModePreferenceStoring` — with couch views at 10-foot scale (`CouchLayout`, `CouchScale`: every value designed at
  1080pt tall and scaled by screen height, so 1080p and 4K match).
  - **Home** per §3.7: header (wordmark, status pill with the real controller state and an `h:mm` clock every 15s),
    the hero (same carousel and copy generator, focused case pose, arrows as a focus row), the shelves viewport with
    soft fade masks and 400pt rows. Shelves: "Continue playing" (7 most recently played) and "Everything, A–Z"
    (ignoring "The"). **"Bring a friend" is hidden**: the library has no player count (as Home's curated shelves).
  - **Library**: the whole shelf A–Z (so letter jumps make sense) as a grid of couch tiles.
  - **Detail**: the standing case, "{genre} · {year}", title, summary, the first five real specs, Play and Favourite.
    A game that can't start says why; a missing user file says "Please provide your ___ at the desk".
  - **Builds**: the list and the selected build's panel with segmented progress. Starting/stopping/adding builds
    stays at the desk; A opens the build's game.
  - **Settings**: Appearance, Music, Music volume, Interface sounds, Open in, Controller rumble, Exit to desktop.
    Folders, players and API keys need typing or pickers, so they stay at the desk (a note says so).
  - **Nav column** (my call): the nav island at 10-foot scale as a frost panel that slides in from the left when Left
    reaches it from a screen's first column (or past the hero's left arrow), so Home keeps the spec's exact layout.
- **Focus model:** all of it in `CouchNavigator`, a pure reducer from `CouchInput` to `CouchFocusState` +
  `CouchEffect`s (rows −2/−1/0…n, per-shelf columns and starts, arrows as focus stops, paging by V tiles,
  settling off arrows, LB/RB anywhere on Home, Left/Right on the hero, LT/RT letter jumps with the 1100ms toast,
  A plays, X opens details, B "You're home" on Home and back elsewhere, Home "Already home", View → desktop,
  Menu → Settings, reading-order grid, overlays). `CouchViewModel` carries the effects out (sounds through
  `AudioController`, rumble when on and supported). **No auto-advance while navigating:** the 7s timer runs only
  while focus rests on the hero with nothing over it; every input restarts the cycle (`CouchAutoAdvanceKey`).
- **Controller:** GameController (`GameControllerInputSource`, salvaged). Buttons act **by physical position for
  every controller**: east selects, south goes back, north opens details (on a Switch Pro Controller: A, B, X as
  printed). Shoulders switch the hero game, triggers jump letters, − (View/Options) leaves couch, + (Menu) opens
  couch Settings, Home is couch's own while it shows (`preferredSystemGestureState = .disabled`). Repeat 280ms then
  110ms, stick threshold 0.6. Prompts follow `productCategory` (Nintendo, Xbox letters, PlayStation shapes,
  generic as Xbox) and default to Nintendo. Rumble via GameController haptics; a Switch Pro Controller's HD Rumble
  isn't exposed by Apple's framework, so it is silent there. Development keys exist and are never advertised.
- **Launch:** A shows the launch phase in the game's wash ("Here we go…", "Starting {short}" — the app that runs it
  is never named), then the real handoff takes over. `CouchLaunchPolicy`: couch → `.fullScreen` unless the game is
  marked **"Open windowed"** in the desktop Manage sheet (stored as a per-game `UserDefaults` set,
  `couch.windowedGameIDs`, so no schema change); desktop → `.standard`, unchanged.
- **Resume/Close:** when nativehaul becomes active while a game runs in couch (the Home button through macOS
  Controller Shortcuts), the Paused card offers Resume (the game is activated, nativehaul hides again) or Close
  (`CloseGameFlow`: graceful terminate first; after ~10s, if still running, **offer** Force quit with an
  unsaved-progress warning; "Keep waiting" asks again). Never Accessibility; no copy promises a game stays in front.
- **ADR 0030 amendment (couch only):** once the game has **exited**, couch brings nativehaul back in front
  (`GameSessionHandoff.restoresInFront` → `NSApp.unhide`), because the controller only reaches the frontmost app and
  the TV plan's flow returns to the shelf. Desktop restores quietly, as before. Nothing takes the focus while a game
  runs. The background-events fallback (Share+Options hold) is not built: M1 had none, and bringing nativehaul
  forward from the background would take the focus during a game.

## Consequences
- Verified by unit tests (navigator, mapping, glyph symbols, letter jumps, stick/repeat timing, keyboard map,
  auto-advance rule, prompts, launch style, windowed store, close timing, handoff, view model) and offscreen renders
  at 1080p (`/Users/jrbaprz/Projects/nativehaul/.recovery/home/nativehaul-0.1.0-work/screens/phase5-*`). The window-snapshot renders draw the 3D hero case at the
  window's origin (a snapshot artifact; `phase5-home-imagerenderer-*` shows it in place).
- **Not verified on hardware:** no controller was available. Face-button positions on a Switch Pro Controller,
  stick repeat, Home gesture suppression, haptics, entering/leaving full screen on a TV, `DM_FULLSCREEN` reaching
  each build, emulator full-screen flags, Resume re-activating the game, and whether macOS honours the in-front
  restore after a game exits.
- Convenience over configuration (ADR 0016): couch needs no setup; "Open windowed" is an override for builds that
  misbehave full screen.
