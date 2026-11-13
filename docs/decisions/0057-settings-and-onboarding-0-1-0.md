# ADR 0057 — Settings and Onboarding for 0.1.0

**Status:** Accepted · 2026-11-13 (0.1.0 overnight run, Phase 4; spec `nativehaul-swift-spec.md` §1.2, §1.4, §1.12,
§3.5, §3.6, §4.4, §5, §6, §7 items 2 and 4; TV plan Q4, Q7, Q8 and "Onboarding design"). Copy marked *pending* awaits
J.R's approval.

## Context
Before this phase, Settings was the old tabbed settings embedded inside the new page, plus a separate Settings
window. Onboarding was a checklist sheet. The Make design has one in-window Settings page of grouped rows, and
onboarding as a friendly chat that ends with the couch offer. The Make code is full of mock data: fake players,
a fake key, "18 games", "412 GB" and a Lockpick hint. The app must use real state, and it must never hint at where
the keys come from.

## Decision
### Settings (`Features/Settings`, `Features/Players`)
- **One page**, opened from the nav island and from **⌘,**. There is no separate Settings window: the `Settings`
  scene is gone and `CommandGroup(replacing: .appSettings)` navigates the shell. "Configure Game Folders…" does the
  same.
- **The groups, in order:**
  - **Appearance**: the segmented pill on `AppearanceController`.
  - **Audio**: Music, volume and Interface sounds on `AudioController`, plus the CC0 credit. Peach wash, my choice.
  - **Directories**: every game folder (Change… / Remove / Add a folder… / Scan now). Adding or changing a folder
    scans straight away.
    - **Install location** is the engine's real `outputDirectory`.
    - **Switch keys file** shows the detected path. The **Valid** badge appears only when the file is really there:
      it exists, it is a file, and it is not empty. Change… sets an override (the user's pick); "Use detected" drops
      it.
  - **Players**: one row per real emulator app, with its version read from its bundle, plus the nxnative engine row.
    The engine row has its path, Choose…, "Use detected" and the real on/off switch. A missing engine is a plain
    missing-file line.
  - **API keys**: SteamGridDB, the IGDB client ID and secret, and the RetroAchievements username and key, through
    the existing view models.
  - **Couch mode**: "Open in" and controller rumble.
  - **Behind the scenes**: nativehaul updates inline (Check for Updates… and the automatic switch). Every older form
    is one click away in a sheet: emulator updates, emulators by system, playtime tracking, build engine details.
- **The default player is per system.** The router really chooses an emulator per system, so an emulator is
  "Default" when every system it runs routes to it. "Make default" routes all of them to it, and the catalog default
  is stored as "no override".
- **Rows that are left out**: emulator enable toggles, because the app has no such concept. Pre-build shaders,
  because the engine has no such option.
- **API keys**: fields always start empty, and "Saved" shows when a key is stored. The stored-state reads moved off
  the main thread (ADR 0044): `SteamGridDBKeyStoring.hasKeyOffMain()` and `refresh()` on the IGDB and Artwork view
  models.
- **`ModePreferenceStoring`** (`Features/Shell/Services`) persists `defaultMode` (default desktop) and
  `isRumbleEnabled` (default on), with a UserDefaults store and an in-memory mock. Phase 5 reads them.
- **The footer** reads `"nativehaul {AppInfo.version} · for Switch ports and emulator classics on your Mac"`.

### Onboarding (`Features/Onboarding`)
- **Where it runs**: `RootView` shows `OnboardingScreen` *in place of* the shell when onboarding isn't done, or after
  "Take the welcome tour again". It never shows over a running game. Music stays off: the existing
  `shellDidDisappear` hook handles that. It never touches the appearance, and a replay resets nothing.
- **The chat engine** (spec §4.4):
  - **One view per message.** `ChatTypist` adds each message once, with its full text.
  - **The reveal.** `TypingSchedule` (pure, tested) emits dots → reveal(n) → send → ready at the exact timings.
    `ChatBubble` lays out the full text from the first frame. A `TextRenderer` (`BubbleRevealRenderer`) draws only
    the runs marked `RevealedRun`. The characters never change, so size and line breaks never move.
  - **Caret and dots.** The caret is drawn in the renderer, outside the flow. The dots sit inside the sized bubble.
  - **Follow logic.** `ChatFollow` (pure, tested) uses the scroll phase to tell the reader's scrolls from ours. Only
    a new bubble scrolls. Answering resumes following.
  - **Scroll behaviour.** Drag-to-scroll has a 5pt threshold and the grabbing cursor. Reduce Motion reveals
    instantly.
- **Real effects** through `OnboardingSetupPerforming` (live: `LiveOnboardingSetup`; mock: `MockOnboardingSetup`):
  - **Games folder.** It is added through `GameFolderStoring` and scanned by the normal importer.
  - **What the scan found.** The count is the library's games under that folder. Titles are sorted A–Z, and covers
    with art come first, up to 18.
  - **The offered folder.** "Use {folder}" is offered only for a usual folder that exists and isn't set up yet:
    `~/Games`, then `~/Switch/Games`. If neither exists, the actions are "I'll show you" and "I'll add them later".
  - **The replay** names the folders already set up instead of asking again.
  - **Disk.** It reports the install location's real volume. "Use my external drive" appears only when a writable
    external, local, non-disk-image volume is mounted. It writes `<volume>/nativehaul` as the engine output folder.
  - **Keys.** A detected file is acknowledged and never asked for. Otherwise the user's pick or drop is placed with
    `UserFilePlacer` at the engine's keys destination, never overwriting. Skipping is always one click.
  - **Players.** The beat is informative: the per-system default already works with no tinkering, and a single pick
    would silently override several systems. Convenience wins (ADR 0016).
  - **Final.** The choice writes `defaultMode`. The FileVault note reads `fdesetup status` and only informs.
- **Old code removed**: `OnboardingViewModel`, the checklist, module and done views, and their tests. The
  `OnboardingStoring` and `OnboardingStatusProviding` services stay.

## Consequences
- Settings and onboarding are fully token-driven. Every new view has a `#Preview`, and the logic is unit-tested
  (612 tests).
- Phase 5 reads `ModePreferenceStoring` at launch to drive couch mode.
- A keys override that points into a protected folder is read there whenever Settings opens. That folder was the
  user's own pick. *Needs J.R's eyes.*
- The look and the typing feel are verified only in offscreen renders (`~/nativehaul-0.1.0-work/screens/phase4-*`),
  not on the running app.

## Copy (pending J.R)
See PROGRESS "0.1.0 · Phase 4" and the phase report for the verbatim list: the footer, the keys and keysHelp lines,
the steps card, the FileVault notes, the player and zero-games lines, "Use my external drive", and the Settings intro.
