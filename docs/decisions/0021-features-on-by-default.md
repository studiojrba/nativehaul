# ADR 0021 — Features ship on; files the user already has are detected

**Status:** Accepted · 2026-11-06 · J.R product correction

## Context
The live Builds page said "NXNative Module Off — Enable the module and choose your own engine in Settings to build
native apps." J.R flagged this directly: it breaks zero-tinker (ADR 0016). His words in substance: NXNative should
be **100% on by default**. Only the things a user has to provide (prod.keys, a game file) are not on by default,
and the module must be **ready** for users who already have the engine and keys.

## Decision
- **On by default.** `EngineConfiguration` no longer stores `isEnabled`. It stores `isSwitchedOffByUser: Bool?`;
  `nil` means on. `isEnabled` is computed from it.
  - Fresh installs: on.
  - **Untouched existing installs:** settings saved before this ADR carry `isEnabled: false`, which was the old
    default, not a choice. That key is ignored, so they come up on. That includes J.R's install.
  - An **explicit off** in Settings (the toggle, then Save) is stored and respected. The Builds page then says
    "NXNative Builds is turned off — You turned it off in Settings." with a **Turn On** button.
  - Trade-off: a user who turned the old toggle on and then off again before this change can't be told apart from
    one who never touched it, so they also come up on. Convenience wins (ADR 0016); one click in Settings turns it
    off again.
- **Engine auto-detection** (`NXNativeLocator`, read-only existence checks). The Settings engine path is an
  **override only**. When it is empty, the first usable file (an executable, or a `.sh`/`.zsh`/`.py` script) in
  this order is used:
  1. A stand-alone tool named `nxnative`, `nxnative.sh` or `nxnative.py` in `~/Switch`, `~/Switch/Engine`,
     `~/Switch/Tools`.
  2. An nxnative checkout's `scripts/build_ipa_from_nsp.py` in `~/Switch/nxnative`,
     (originally also another app's bundled copy, which is how J.R's engine was found; removed by ADR 0027),
     `~/nxnative`, `~/Developer/nxnative`, `~/Projects/nxnative`.
  3. The same tool names in a few user and Homebrew folders.
  **Narrowed by ADR 0027:** `~/Switch` tools, then `~/Switch/nxnative`, then Homebrew; never another app's copy.
  The preflight's "engine must live outside the app bundle" check still applies to whatever is found.
- **No engine anywhere** is a missing-file state, never a setup step. The Builds page opens normally, with a
  banner: "No nxnative engine found on this Mac — Retriever looked in ~/Switch and Homebrew (the wording since ADR 0027) and the
  other usual places. If your engine is somewhere else, choose it." It has a **Choose Engine…** button, which saves
  the choice as the override and re-checks queued jobs.
- **prod.keys auto-detection.** `keysPath` is an override only. When it is unset, the first existing file in this
  order is used silently:
  1. `~/Switch/ProdKeys/prod.keys`
  2. `prod.keys` in any other `~/Switch/ProdKeys…` folder, newest name first. J.R's real keys are in
     `~/Switch/ProdKeys.NET-v22.5.0/`, so an exact `ProdKeys` path alone would have missed them.
  3. `~/.switch/prod.keys` (also nxnative's own default)
  4. `~/Switch/prod.keys`, `~/Switch/Keys/prod.keys`
  5. `~/Library/Application Support/Ryujinx/system/prod.keys`,
     `~/Library/Application Support/yuzu/keys/prod.keys`, `~/.local/share/yuzu/keys/prod.keys`
  "Please provide your prod.keys" appears **only** when none exist. The user's file is then copied to
  `~/.switch/prod.keys`, where the next detection finds it.
- **Game file** stays per build, through the Add Build prompt ("Please provide your game file (.nsp/.xci)"). It is
  inherent to a build — not a setting and not a gate on the module.
- Detected paths are resolved at use time and **never saved**, so moving a file later just works.
- **Settings** shows what was found ("… (found automatically)") or the override ("… (your choice)"), with
  **Use Detected** to drop an engine override.
- **Rule recorded in CLAUDE.md** beside zero-tinker: features ship on by default; only user-provided files gate
  them, and files the user already has are detected, not re-demanded.

## Consequences
- J.R's Builds page opens enabled with his detected engine and his `ProdKeys.NET-v22.5.0` keys already
  in use. Nothing to toggle.
- **Not solved here:** being *found* is not the same as *building* successfully. nxnative's real command line
  (`build_ipa_from_nsp.py <game folder> -k <keys> --platform mac-app -o <app>`) differs from the default argument
  template (`{input} {output}`), and its script needs its own Python environment, not `/usr/bin/python3`. Making a
  detected nxnative checkout build with zero edits is a separate follow-up.
- J.R's built games carry a different library marker, but the default hidden library folder is
  `.nxnative-lib`. The cleanup step uses that name, so it is worth aligning in the same follow-up.
