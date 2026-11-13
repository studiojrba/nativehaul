# ADR 0052 — TV mode, milestone M1: the TV shell

> **Amended for 0.1.0 (2026-11-13, ADR 0058): couch mirrors desktop.** The standalone TV screens below (shelves
> Recently Played/Switch/Emulated/Other, the grid option, the Start menu with power actions, the TVMode feature
> folder) were superseded and not brought back. Salvaged from M1 into `Features/Couch` and `Features/Launch`: the
> GameController input source, controller families and glyphs, the full-screen launch (`LaunchStyle`,
> `FullScreenLaunch`, `DM_FULLSCREEN`, documented emulator flags), the full-screen window handling and their tests.
> Changed on the way: the design glyph set is Nintendo's (select stays the button labelled A, as in M1), the per-game "Open windowed" override is a per-game `UserDefaults` set (no
> `Game` schema field), and "TV mode" is called couch mode. See ADR 0058 for the 0.1.0 design.

**Status:** Accepted · 2026-11-12 (amended 2026-11-13). This follows J.R's TV mode plan (`~/nativehaul-tv-mode-plan.md`), his nine
decisions of Nov 12, and the overnight brief. M1 only.

## Context
J.R wants a couch mode: nativehaul on a Mac mini connected to his TV, driven by a Switch Pro Controller. The plan
splits it into milestones:
- **M1:** the shell, navigation, detail screen and launch hooks;
- **M2:** the play loop (Resume/Close);
- **M3:** boot behaviour and onboarding;
- **M4:** an external library drive;
- **M5:** polish.

Desktop mode must not change.

## Decision
- **Where TV mode lives:** inside the main window. "Enter TV Mode" comes from the View menu (⌃⌘T) or Settings →
  TV Mode, as a `TVModeRequest` notification.
  - `TVModeHost` switches the window to full screen (macOS hides the menu bar and Dock) and covers the desktop
    layout with `TVModeView`.
  - The desktop layout stays alive underneath. "Exit TV Mode" restores the window exactly as it was, and leaves it
    full screen only if it already was.
  - No second window is opened and nothing is activated, which keeps ADR 0030's rule that nativehaul never takes
    the focus (`LaunchFocusTests` bans `openWindow`).
- **Library:**
  - Shelves are Recently Played, Switch, Emulated and Other, with empty shelves left out.
  - Horizontal shelves are the default; a grid of the current shelf is the option (Settings or the TV menu).
  - The focused game's art fills the backdrop under a dark scrim.
- **10-foot sizing (`TVMetrics`, `DesignTokens.TVMode`):** everything is a share of the screen height.
  - Titles are 4.5%, body text 2.6%, and the safe area 5% on every edge.
  - 4K is exactly twice 1080p.
- **Focus without borders:** the focused tile grows 9% and lifts on a soft shadow, with its title underneath; other
  tiles dim. Reduce Motion turns the animation off.
  - The plan's accent-coloured title is held back: the accent stays on Play, nav and links (`EnergyPassTests`).
    That's J.R's call to change.
- **Controller (`GameControllerInputSource`, GameController framework):**
  - D-pad or left stick moves, and held directions repeat.
  - Select is the button labelled A (Cross on PlayStation); Back is the one labelled B (Circle).
  - The top face button opens details; the shoulders switch shelves; the triggers jump by first letter.
  - +, Options or Menu opens the TV menu.
  - GameController reports face buttons by position, so on Nintendo controllers Select is the east button and Back
    the south one (`ControllerMapping`).
  - Prompts follow the connected controller (`ControllerGlyphs`): Nintendo letters, PlayStation shapes, Xbox
    letters, or key caps when no controller is connected. A test checks every SF Symbol exists.
- **Keyboard:** arrows, Return, Esc, Space, Tab or Shift-Tab, comma and period, and M. It's there for testing and
  for anyone without a controller.
- **Detail screen:** reuses the Builds page media. The trailer comes first when there is one; otherwise the Builds
  showcase slideshow (`BuildShowcaseView`, now with a `maxHeight`). Then the title, a subtitle, the summary, and how
  the game will open.
- **Launch hook (`LaunchStyle`, `FullScreenLaunch`):** TV mode launches with `.fullScreen`, or `.windowed` for
  games with "Open windowed in TV mode" turned on. That per-game switch is in desktop mode's Manage sheet, stored as
  `Game.launchesWindowedInTVMode`.
  - nxnative builds declare their runtime switches in `Info.plist` → `DMSettings`, and all 17 of J.R's builds
    declare `DM_FULLSCREEN`. nativehaul sets it in the launch environment: `1` for full screen, `0` for windowed.
  - Emulators get their documented full-screen flag: RetroArch `-f`, Dolphin
    `-C Dolphin.Display.Fullscreen=True`, PCSX2 `-fullscreen`, melonDS `-f`, PPSSPP `--fullscreen`.
  - Desktop launches use `.standard` and are byte-for-byte what they were.
- **Start/Options menu:**
  - Layout (shelves or grid).
  - Audio output: the current device, read from Core Audio, with a note to change it in Control Center.
  - Sleep (`pmset sleepnow`).
  - Restart and Shut Down, through System Events, so other apps are asked to quit first.
  - Exit TV Mode.
  - Every power action asks for confirmation.
- **Not in M1:**
  - the onboarding mode pick and starting in TV mode at login (M3);
  - Resume/Close and the Home-button return (M2);
  - Offline drives (M4);
  - idle dim and the on-screen keyboard (M5).

## Consequences
- **Verified by tests and offscreen renders only.** The 465-test suite covers the navigation, mapping, metrics,
  launch planning and view-model rules. Renders at 1080p and 4K show the shelves, grid, detail screen, menu and
  Nintendo prompts.
- **Not verified on real hardware:**
  - a Switch Pro Controller's face-button positions, stick repeat, and triggers as buttons;
  - whether `DM_FULLSCREEN` set through `NSWorkspace.OpenConfiguration.environment` reaches each build;
  - each emulator's full-screen flag;
  - entering and leaving full screen on the TV;
  - the Automation prompt for Restart and Shut Down, which may also need the hardened-runtime Apple-events
    entitlement.
- **Schema:** adding `Game.launchesWindowedInTVMode` (default false) is an additive SwiftData change.
