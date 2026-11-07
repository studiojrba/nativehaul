# ADR 0027 — The engine is upstream nxnative, never another app's copy

**Status:** Accepted · 2026-11-07 · J.R product rule (00:35 EST) · narrows ADR 0021 and ADR 0022

## Context
ADR 0021's detection searched, among other places, another app's Application Support folder, which held a bundled
copy of nxnative. J.R saw a preflight line pointing at it. Retriever must not be associated with other front ends for
the engine: the engine is nxnative, full stop.

## Decision
- **Auto-detection finds standalone upstream nxnative only**, in this order:
  1. `nxnative`, `nxnative.sh` or `nxnative.py` in `~/Switch`, `~/Switch/Engine`, `~/Switch/Tools`;
  2. a checkout at `~/Switch/nxnative` (its `scripts/build_ipa_from_nsp.py`);
  3. the same tool names in Homebrew: `/opt/homebrew/bin`, then `/usr/local/bin`.
  A Settings engine path is still the user's own choice and overrides all of this.
- **Never another app's copy:** a path that resolves (symlinks included) inside an app bundle (`.app/`) or under
  `~/Library/Application Support/` is never auto-detected. Other apps' tool names are gone from the search too.
- **No engine found** shows the same banner as before: "No nxnative engine found on this Mac — Retriever looked in
  ~/Switch and Homebrew. If your engine is somewhere else, choose it." with **Choose Engine…**.
- **The derived run uses only the checkout's own environment:** `<checkout>/.venv`, then `<checkout>/../.venv`,
  else the system `python3` with a preflight warning pointing at nxnative's README. Another app's Python environment
  is never used.
- **Library layout:** checkout builds still file one folder per game, now with Retriever's own `.nxnative-lib`
  marker. The library scanner keeps a read-only constant for a marker that older ports in users' game folders
  already carry, so J.R's existing ports stay recognised; it is never written.
- **No other front end is named** in UI copy, preflight lines or docs. The ADRs and PROGRESS were reworded to say
  "another app's bundled copy" where history needs it.
- The rule is recorded in CLAUDE.md.

## Consequences
- On J.R's Mac today, the only copy is the app-bundled one, so the Builds page will show **No nxnative engine found**
  until a standalone nxnative exists (for example a clone at `~/Switch/nxnative` with its `.venv`), or until he
  chooses an engine himself.
- Tonight's Ocarina build was started against that copy before this change and finishes as-is (J.R was told).
  This change governs what Retriever detects and displays from now on.
