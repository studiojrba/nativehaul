# ADR 0030 — Play hands the game the focus; Retriever never takes it back

- Status: accepted, verified (QA Finding #6 follow-up, 2026-11-07)
- Branch: `feature/nxnative-first-launch-guidance`

## Context
QA Finding #6 showed that an nxnative-built game only draws while its window is in front and focused. When covered or
unfocused, the game pauses itself: the screen goes black and the music may keep playing. One-click play therefore
depends on Retriever handing the game the focus and never taking it back.

## Decision
- Play opens every game app activated (`NSWorkspace.OpenConfiguration.activates = true`), via
  `WorkspaceGameLauncher.openConfiguration(arguments:)`.
- After Play, Retriever never raises its own window, opens a sheet or alert, or otherwise takes the focus. Play's only
  feedback is inline text under the button (the option used, or an error).
- Audit, 2026-11-07:
  - No Swift source activates the app, orders a window front, requests attention or opens a window.
  - The playtime watcher posts no notifications.
  - The library alert fires only from user-started import and metadata actions, never from a launch or a tracked
    session.
- Regression tests (`LaunchFocusTests`):
  - games open activated;
  - a source scan forbids focus-taking APIs (`NSApp.activate`, `activate(ignoringOtherApps`, `makeKeyAndOrderFront`,
    `orderFrontRegardless`, `requestUserAttention`, `openWindow`, `NSAlert(`);
  - Play produces no file request or error state.

## Consequences
- A game that goes black because the user covered it is the user's window arrangement. The knowledge base case
  `nxnative-game-black-screen` explains it in plain words.
- Any future feature that must get the user's attention while a game runs (for example "build finished") has to do so
  without activating Retriever, such as a notification banner. The source scan enforces this.
- Not exercised live by clicking Play: there is no accessibility access on the QA Mac, and a live run would add a
  tracked session to J.R's real library.

## Amendment — Layer 1: a clean handoff for the whole session (scoped, not built; J.R, 2026-11-07 19:28 EST)
J.R asked whether games launched in Retriever can be guaranteed to stay the topmost window. The answer comes in three
layers. Layers 2 and 3 are in ADR 0032. Layer 1 needs no permission and extends this ADR from "Play doesn't take
focus" to "Retriever stays out of the way for the whole time the game runs". That covers the moment of launch, which
is where tonight's failures happened.

**Behaviour:**
- **After a successful tracked `.app` launch,** Retriever takes its windows out from over the game.
  - It hides itself with `NSApp.hide`, which covers the main window, Settings and any panels.
  - It never re-activates itself while the game runs.
- **While a launched game runs,** Retriever shows nothing over it.
  - Library and launch alerts, sheets and onboarding requests are deferred and shown after restore.
  - No notification banners, no Dock bounce.
- **When the game exits,** Retriever restores itself with `NSApp.unhideWithoutActivation()`.
  - Whatever the user is doing next keeps the focus.
  - The ADR 0030 source scan stays green, because `NSApp.activate` is still never called.
- **The user wins:**
  - If the user brings Retriever back while the game runs (Dock icon, Cmd-Tab), it stays visible and is never hidden
    again for that session.
  - If no launched process is seen within a short grace period (about 10 s, a named constant), Retriever restores
    itself and the game is treated as not started.
- **Scope:**
  - Applies to tracked `.app` launches: nxnative ports, Mac-native games and emulator apps.
  - Not applied to `steam://` and CrossOver launches. Their game process isn't the one Retriever opened, so the
    handoff can't be tied to its exit. Those keep the plain ADR 0030 behaviour until the watcher can attribute them.
- **Default on (ADR 0021).** A Settings switch, "Hide Retriever while a game is running", turns it off.

**Design:**
- A `GameSessionHandoff` coordinator, `@MainActor`, driven by:
  - Play success from `GameLaunchViewModel`;
  - process launch and exit events the `PlaytimeWatcher` already observes.
- Window control behind a protocol, `AppVisibilityControlling` (hide, unhide without activation, is visible), with
  `NSApp` live and a mock for tests.
- An alert gate that `RootView`'s alert and sheet presenters consult. Deferred items replay on restore.

**Tests (mocks only):**
- hides after a tracked launch, not after a URL launch;
- restores without activation when the game exits;
- defers and replays alerts;
- the user un-hiding wins;
- the grace-period timeout restores;
- turning it off in Settings disables it;
- the source scan still forbids `NSApp.activate`.

**Build note:** verifying it live means running the canonical build alongside a game. Per CLAUDE.md, that waits until
J.R isn't playing, and it goes through Retriever's Play button.

## Layer 1 built — approved minimal scope (J.R, 2026-11-08)
J.R approved Layer 1 in its minimal form. After Play, Retriever hides or orders out its own window while a launched
game runs and restores it when the game exits. No sheets, alerts or notifications appear over a running game.
Nothing else about launch changes. Built on `feature/launch-handoff`:

- **`GameSessionHandoff`:**
  - after a successful **tracked `.app`** launch (the target opens an `.app`), it calls `NSApp.hide`;
  - it watches that app's processes with its own `WorkspaceRunningApplicationObserver`;
  - when the last one exits, it calls `NSApp.unhideWithoutActivation()`.
  - A port's launcher and its game host are both counted.
  - A game already running at Play counts as seen.
  - If the app never appears within 10 s, Retriever restores itself.
- **Gating:** `RootView`'s library alert and the onboarding sheet are held while a game runs, and appear when
  Retriever is back. There are no notification banners.
- **Not in this scope (unchanged from plain ADR 0030):**
  - `steam://` and CrossOver launches;
  - a Settings switch;
  - re-hiding after the user brings Retriever back.
- The launch path itself (planner, `WorkspaceGameLauncher`, `activates = true`) is untouched. The source scan still
  forbids every focus-taking API.
- **Tests:** `GameSessionHandoffTests` (mocks only).
- Not exercised live: no Play clicks against J.R's library, per the brief.
