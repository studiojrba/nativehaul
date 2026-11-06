# ADR 0018 — First-run onboarding: an accelerator, never a gate

**Status:** Accepted · 2026-11-06

## Context
J.R wants a first-run walkthrough. It starts with "Hey! I'm Retriever.", says what the app does, and covers
trust (open source, no account, no telemetry, no weird permissions) **before** asking for any setup. Then it
offers a checklist of optional modules, each module's own flow, and a Done screen.

## Decision
- **Screens:**
  1. **Welcome**, with the trust block and "Set up later" (skips everything in one click).
  2. **Checklist hub**: "What do you want to set up now?" with J.R's reassurance ("You can run setup again
     later…").
  3. **One step per checked module**, in checklist order.
  4. **Done**: what's set up, what was skipped and where to find it later, then into the library.
- **Modules** reuse their existing flows unchanged:
  - **Find your games** (pre-checked): the Game Folders list and scan.
  - **Steam**: the steam-signin branch's `SteamConnectionView`.
  - **CrossOver**: detection plus the golden-bottle offer, in J.R's words (`CrossOverSetupView` over the same
    `BottleInstalling`).
  - **Switch ports**: the Tracking games-folder settings.
- **Emulators** are listed as "coming soon" (not selectable). The emulator-launch branch adds the module to
  `OnboardingModule.available` and its step. The seam is the `.emulators` case, which already has copy and a
  "find it later" location.
- **State:** "finished or skipped" is stored in `UserDefaults`, so the walkthrough never shows unasked again.
  Settings → General → **Run setup again** reopens it. The preview environment counts as already onboarded.
- **The Done screen reports what is actually true** (`LiveOnboardingStatus` reads each feature's own state), not
  which boxes were ticked.

## Zero-tinker audit (ADR 0016)
- The walkthrough is optional. Without it, the launch-time upkeep still finds:
  - Mac Steam and CrossOver-bottle Steam installs;
  - CrossOver launchers and bottles;
  - **`~/Switch/Games`** — new on this branch: the folder scan now includes the standard Switch-ports folder
    whenever it exists, even if no folders were configured.
- Closing the walkthrough reruns that upkeep, so anything just set up appears straight away.

## Trust copy — honesty notes
- "It only looks in folders you point it at" was qualified to "…plus the standard places games install to (Steam,
  CrossOver, ~/Switch/Games)", because zero-tinker detection reads those places by default. The unqualified
  sentence would not have been true.
- "Completely open source": the GitHub repo is public. When this ADR was written it had no LICENSE file. J.R
  chose MIT (Studio Jrba inc.), and it was added in `feature/mit-license`, so the line is now strictly true.
- "Never asks for Accessibility or Screen Recording": true. Playtime tracking uses NSWorkspace launch
  notifications, which need no permission.
