# ADR 0019 — Shelf and router: emulator launch, plus the user-provided-files pattern

**Status:** Accepted · 2026-11-06 · owner directives

## Context
J.R's principle: **Retriever is the shelf and the router, never the engine.** It works like the Cocoon launcher on
his AYN Thor: one front end, with each kind of game run by the specialist app that owns it. Retriever already
routes native `.app` bundles (including nxnative ports), Mac Steam (`steam://`) and Windows Steam (CrossOver
bottles). Emulators should be a new route in the same model, with no emulation built in.

A second directive covers files only the user can supply, such as a BIOS, `prod.keys` or a game dump. Retriever
asks with one prompt, "Please provide your ___", and never obtains the file itself.

Both rules are now in `CLAUDE.md`.

## Decision
- **Emulator profiles** (`EmulatorProfile`, `EmulatorCatalog`): each profile gives the app name, the systems it
  runs, an argument template (`{rom}`, `{core}`), whether it uses a RetroArch core per system, its official page,
  and any BIOS it needs.
  - Only emulators whose command-line launch is documented are seeded:
    - RetroArch: `-L <core> <rom>`
    - Dolphin: `-e <rom>`
    - PCSX2: `-- <rom>`
    - melonDS and PPSSPP: the ROM path as the only argument
  - DeSmuME, DuckStation and others are left to the open model until their syntax is confirmed.
- **Defaults and overrides:**
  - RetroArch is the default wherever it has a core: gambatte, mGBA, Nestopia, Snes9x, Mupen64Plus-Next,
    melonDS, Dolphin, PCSX ReARMed, PPSSPP and Genesis Plus GX.
  - PCSX2 is the default for PlayStation 2, because RetroArch has no reliable PS2 core on macOS.
  - Per-system overrides live in Settings → Emulators. They're the optional tinker, never required (ADR 0016).
- **ROM library:**
  - The existing Game Folders scan also finds ROMs (up to four levels deep; hidden items and app bundles are
    skipped). Each ROM becomes one entry with platform `emulated`, its system, and the ROM path.
  - Unique extensions (`.gba`, `.sfc`, `.z64`, `.nds`, …) decide the system on their own.
  - Shared extensions (`.iso`, `.chd`, `.cue`, `.rvz`, `.gcz`, `.pbp`) need a folder name that says the system,
    such as "PS2", "GameCube" or "PlayStation". Otherwise the file is **left out**, not guessed. A "Wii U"
    folder is excluded. `.bin` is skipped because it is a `.cue`'s data track.
  - A ROM entry never merges with a Mac app or Steam game of the same title, because a remake isn't the original.
- **Launch route:** `GameLaunchViewModel` sends emulated entries to `EmulatorRouter`.
  - The emulator opens through NSWorkspace with arguments, as a new instance, so the arguments reach it even if
    it's already running.
  - Honest states:
    - ROM missing.
    - **"RetroArch isn't installed."** plus its official page (the same pattern as the CrossOver gate).
    - Core not downloaded yet, with RetroArch's own Online Updater → Core Downloader named.
    - **"Please provide your PlayStation 2 BIOS"**.
- **Playtime:** launching through an emulator is tracked like any other route. Before launch, the watcher is told
  to credit the **next** launch of that emulator app to this game (`SessionTracker.expectLaunch`, one-shot).
- **Metadata:** the existing pass covers ROMs through SteamGridDB. The Steam store isn't asked about emulated
  entries, because a title search could match a modern re-release.
- **User-provided files:**
  - `UserFileRequest`, `ProvideFilePrompt` and `UserFilePlacer` form one reusable pattern: plain copy naming the
    file and why it's needed, then a file picker. For a BIOS, the user's file is copied into the emulator's
    folder (PCSX2: `~/Library/Application Support/PCSX2/bios`). An existing file is never overwritten.
  - No sources, links or hints are ever given.
  - The component-updates branch's BIOS rule follows this pattern: what's prohibited is the app obtaining the file.
- **Onboarding:** the Emulators checkbox is now live. Its step shows installed emulators and the per-system
  choices, and points ROM folders to "Find your games".

## Consequences
- **Nothing is bundled or downloaded:** no emulators, cores, BIOS files or ROMs.
- **Unverified live:** the argument syntax follows each emulator's documented command line, but no emulator was
  run here. RetroArch core file names follow the macOS buildbot naming.
- **NXNative:** its `prod.keys` and game-file inputs should move to `ProvideFilePrompt` in a follow-up. Its
  current fields already ask for the user's own files and never source them.
