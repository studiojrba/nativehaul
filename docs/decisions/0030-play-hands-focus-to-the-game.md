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
