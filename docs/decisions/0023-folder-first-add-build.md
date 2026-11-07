# ADR 0023 — Folder-first Add Build (J.R's favourite NX2Apple behaviour)

**Status:** Accepted · 2026-11-06 · J.R requirement ("super important")

## Context
In NX2Apple you point the builder at **one folder** holding a random mix of base game, updates and DLC, and it
sorts everything by title ID: one click and go. Retriever's Add Build asked for one file, a hand-typed title and a
title ID. J.R wants NX2Apple's behaviour, for Switch and Switch 2 alike. He also wants the pickers to open in
Downloads, where game files land right after downloading.

## Decision
- **The primary input is a folder** ("Please provide your game folder"). A single-file pick stays as the secondary
  option ("Please provide your game file (.nsp/.xci/.nup)") for a lone base package or a `.nup`. **Both pickers open
  in `~/Downloads`** (`UserFileRequest.startingFolder`, SwiftUI's default file-dialog directory). This only sets the
  starting folder; the user can go anywhere.
  - **Scope (J.R): build side only.** Downloads is just where the build-input pickers open. The game side stays the
    user's own setting and is not touched: where games live (Game Folders), and where built apps and work folders go
    (Settings → NXNative output, work and staging folders, defaulting to `~/Switch/…` as before). No game-side
    default points at Downloads; a test checks this.
- **Scanned before queueing** (`GameFolderScanner`, read-only), using the folder's own files, not subfolders, as
  nxnative does:
  - **Title IDs** come, in order, from:
    1. the `[0100…][vN]` tags in the file name, which is how J.R's real files are named;
    2. otherwise, the `.tik` ticket name inside the NSP/NSZ;
    3. otherwise, the plain `.cnmt.xml` some NSPs carry (`<Id>`, `<Version>`).
    Only the start of the file is read, with no keys and no decryption. Both header forms were checked against
    J.R's real packages.
  - **Grouping** (`SwitchTitleID`):
    - a base ends in `000` with bit 12 clear;
    - its update is the base with `800`;
    - its DLC are the base + `0x1000` + n (n ≥ 1).
    The sheet shows each game as name, title ID and "Base game · update v1179648 · 26 DLC". The newest update
    version is shown, because nxnative packs the newest by default.
  - **Switch 2** folders pass to the engine as before. The sheet shows "Switch 2 · base game · 2 updates (newest
    v131072) · 2 DLC" for a dump, or "Switch 2 · .nup · v131072" for a NUP.
- **One job per game.** The folder (or lone file) is the job's source; the derived invocation (ADR 0022) hands it to
  nxnative, which re-validates. When a folder holds files of **more than one game**:
  - each game is listed with a checkbox, nothing is preselected, and "Select All" is offered;
  - each chosen game becomes its own job, and the engine gets `--title-id <base>`, so games are never silently mixed;
  - a folder of several `.nup` files lists each one, queued as the file itself.
- **Bad picks fail in the sheet with a plain reason, and nothing is queued:**
  - "No game files found in this folder. Retriever looks for .nsp, .xci, .nsz and .xcz files, a Switch 2 game
    folder, or a .nup file."
  - "This folder has an update for Pikmin 3 Deluxe (0100F4C009322000) but not its base game." This is a real case:
    J.R's Pikmin 3 Deluxe folder.
  - A lone update or DLC file: "This file is an update for …, not its base game. Choose the base game's file, or the
    folder holding both."
  - Updates or DLC whose base is missing, sitting beside a real game, are listed as "Skipped: …". Files whose ID
    can't be read are noted; if nothing else is found, they form one game for the engine to sort.
- **One click:**
  - A single detected game is preselected, with its name prefilled from the file name (editable).
  - Architecture defaults to 64-bit. Switch titles are 64-bit, and nxnative refuses others when it builds.
  - The title ID may be blank for a detected-checkout build, since nxnative identifies the game itself.
  Convenience wins (ADR 0016); this reverses the original "architecture must be set by hand" rule from the NXNative
  module.

## Consequences
- J.R's NX2Apple habit works as is: choose a Downloads folder, check what was found, click **Add to Queue**.
- Unchanged: a single `.nup` (the Ocarina test in flight) and a single base `.nsp`.
- File-name tags are trusted first. A wrongly named file is grouped by its name, and the engine catches the mistake
  when it builds.
