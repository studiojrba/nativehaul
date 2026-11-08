# ADR 0031 — Per-title launch recipes (proposal)

- Status: **proposed**, not built (J.R's one-click question, 2026-11-07). Display-mode default **decided** by J.R
  (19:18 EST): new ports launch in Window mode.
- Recorded on: `feature/nxnative-first-launch-guidance`

## Context
J.R asked whether any hack was needed tonight, and how a needed tweak becomes automatic.

- **Tonight:** Ocarina needed none. The diagnosis launched it with `--no-launcher` and the environment overrides
  `DM_SAVED_CHOICES=0 DM_FULLSCREEN=0`, but only to observe it without clicking. A normal Play from the port's own
  launcher works once the window keeps the focus (ADR 0030).
- **Later:** a title may genuinely need a launch flag or an environment override, such as a display mode, an engine
  option, or skipping a broken launcher window.
- **The problem:** today that would mean a Terminal command or a manual setting, which breaks the one-click promise
  (ADR 0016).

## Proposal
A **launch recipe** is stored per title and applied invisibly on Play.

- **What a recipe holds:**
  - **display mode**: Window or Full Screen. **New ports default to Window** (see below);
  - extra arguments, for example `--no-launcher`;
  - environment overrides, for example `DM_FULLSCREEN=0`;
  - an optional note saying why, shown in the game's details for anyone who looks.
- **Key:** the Switch title ID (`DMTitleID` in the port's Info.plist). For other platforms the key is the app path,
  so the recipe survives a rebuild of the same title.
- **Sources, in priority order:**
  1. the user's own override, made in the game's details;
  2. a bundled recipe database shipped with Retriever, the same pattern as the bottle `BundledRecipeDatabase`, with
     entries reviewed and recorded with the QA finding that needed them;
  3. none, which is the default; most titles need nothing.
- **Applying:**
  - `LaunchPlanner` merges the recipe into the launch target, adding arguments and environment.
  - `WorkspaceGameLauncher` passes them through `NSWorkspace.OpenConfiguration.arguments` and `.environment`, still
    activated and still tracked by the playtime watcher.
  - Play stays one click, and the user never sees the recipe unless they open the details.
- **Safety:**
  - Recipes can only add arguments or environment variables to the game's own launch.
  - No recipe runs shell, edits files, or touches keys or game data.
  - Environment keys are allow-listed per engine (`DM_*` for nxnative ports).
  - Every applied recipe is noted in the audit log.
- **Display mode defaults to Window (decided, J.R on Ollie's recommendation, 2026-11-07 19:18 EST):**
  - Why:
    - in tonight's Finding #6 runs, the switch into full screen itself dropped focus, so the game paused black and
      silent;
    - a windowed launch stays visible, shows the game's own progress screen during a cold start, and can be
      recovered (click the window) if anything looks wrong.
  - For nxnative ports this is `DM_FULLSCREEN=0`, set by Retriever on Play unless the title's recipe or the user
    says otherwise.
  - Full Screen stays one toggle away in the game's details, and the user's choice is kept per title.
  - This is a deliberate default, recorded here so it isn't left to whatever the port's launcher last saved.
- **Honesty:** if a recipe can't fix a title, the game's details say so plainly. No hidden workarounds that alter
  game files.

## Open questions to settle before building
- **Saved launcher choices.** The port's launcher remembers its own settings (`launcher.DM_FULLSCREEN` in the
  title's preferences; J.R's Ocarina currently says Full Screen). Tonight's diagnostic needed `DM_SAVED_CHOICES=0`
  to be sure the environment override won. The build has to confirm which wins, and must not erase the user's saved
  choice.
- **The port's own launcher window.** Play in Retriever currently opens the port's launcher window, where the user
  presses Play again. Whether a recipe should skip that window (`--no-launcher`) for a true one-click start is J.R's
  call. It isn't decided here.

## Consequences
- A title that needs a tweak becomes one-click again as soon as its recipe exists, with no Terminal steps and no
  setup.
- The bundled database starts empty. Ocarina gets no entry, because it needed none; like every new port, it would
  get the Window default.
- Building it needs: a `LaunchRecipe` model and store; `LaunchTarget` support for environment variables; the planner
  merge; a details-pane override editor; and tests for merging, the allow-list and auditing. That would be its own
  branch when J.R approves it.
