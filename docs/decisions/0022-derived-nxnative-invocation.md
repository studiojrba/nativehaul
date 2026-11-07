# ADR 0022 — A detected nxnative checkout builds with zero edits (Switch and Switch 2)

**Status:** Accepted · 2026-11-06

## Context
ADR 0021 made NXNative on by default and detection found J.R's engine: NX Play's nxnative checkout at
`~/Library/Application Support/NX Play/nxnative/scripts/build_ipa_from_nsp.py`. Ollie verified it live. But a found
engine still couldn't build without Settings edits, which blocks Phase 1's first real test (a Switch 2 game):
1. The default argument template is `{input} {output}`; nxnative's CLI is
   `build_ipa_from_nsp.py <game folder> -k <keys> --platform mac-app -o <app>`.
2. The script needs NX Play's Python environment; `/usr/bin/python3` lacks nxnative's packages.
3. J.R's games keep an `.nx2apple-library` beside each app; the app defaulted to `.nxnative-lib`.

What was read (read-only) to get this right:
- NX Play's own `nxplay` script: it `cd`s into the checkout, puts the Python environment first on `PATH`, sets
  `VIRTUAL_ENV`, and runs `python3 scripts/build_ipa_from_nsp.py "$game" -k "$keys" --platform mac-app`.
- NX Play's binary adds `~/.local/share/mise/shims`, `/opt/homebrew/bin` and `/opt/homebrew/sbin` to the tools
  path. Its environment lives at `~/Library/Application Support/NX Play/venv`.
- `build_ipa_from_nsp.py`:
  - `nsp_dir` is one game's folder of packages (base, update and DLC together), a Switch 2 dump folder, or a
    `.nup` file.
  - Dumps and NUPs are not encrypted and need no keys.
  - `-o` must end in `.app` for `mac-app`.
  - With no terminal it stops with an error instead of prompting.
- J.R's game folders: `~/Switch/Games/<Title>/<Title>.app` plus `.nx2apple-library`, which is an **empty marker
  file**, not a folder. nxnative doesn't create it.
- The live command shape was checked with nxnative's own `-h`, run through NX Play's Python and environment from
  the checkout.

## Decision
- **`NXNativeCheckout`** is derived when the resolved engine is a checkout's `scripts/build_ipa_from_nsp.py` and the
  argument template is still the default. That covers both detection and a hand-picked checkout script.
  - **Interpreter:** the first `bin/python3` found in `~/Library/Application Support/NX Play/venv`, then
    `<checkout>/.venv`, then `<checkout>/../.venv`. If none exists, `/usr/bin/python3` is used, and preflight shows a
    *warning* (not a failure): "Opening NX Play once sets its environment up."
  - **Environment:** `VIRTUAL_ENV`, and `PATH` set to the environment's `bin`, then the mise shims, `/opt/homebrew/bin`,
    `/opt/homebrew/sbin`, `/usr/local/bin` and the system folders. The runner merges this over Retriever's own
    environment, and stdin is `/dev/null`, so nothing can wait on a prompt.
  - **Working directory:** the checkout, as `nxplay` does.
  - **Arguments:** `<script> <game> [-k <keys>] --platform mac-app -o <work dir>/<Title>.app`.
    - `<game>` is the folder holding a picked package, or the picked dump folder or `.nup`.
    - `-k` is passed only for Switch packages.
    - No `--work-dir` is passed, so nxnative keeps its `<title ID>_build` beside the game files, as NX Play does,
      and NX Play can reuse it later.
- **Game shapes** (`GameSourceShape`, mirroring nxnative's `is_dump`):
  - A package file, or a folder of packages: needs keys. Packages beside a dump win, as in nxnative 1.8.2.
  - A `.nup`, or a dump folder: `base/exefs/main.npdm` with `base/romfs/`, `exefs/main.npdm` with `romfs/`, or
    `updates/<n>/romfs/`. Needs no keys.
- **Switch 2 in the Builds flow:**
  - Add Build has a second prompt, "Please provide your Switch 2 game (its folder or .nup)", which accepts a folder.
  - In preflight, keys show "Not needed for a Switch 2 game.", the title ID may be left blank ("nxnative reads it
    from the game files."), and `04…` title IDs count as retail.
  - Free space is measured over the whole dump folder.
- **Library layout:** for a derived checkout whose library name is still the default, the library is
  `.nx2apple-library` and each app goes into its own folder. Cleanup moves the app to
  `<output>/<Title>/<Title>.app` and, when the engine made no marker, creates the empty `.nx2apple-library` beside
  it (a new `markLibrary` cleanup action). It never writes over an existing item, and like every cleanup step it is
  previewed before it runs. The library scanner already recognises this marker as a Switch port.
- **Overrides keep working:**
  - A customised argument template, or an engine that isn't an nxnative checkout, runs exactly as before: template,
    interpreter by extension, work directory as cwd, `.nxnative-lib`, flat output.
  - A user-set library name is never replaced.
- Convenience wins (ADR 0016): nothing about this is a setting the user has to find.

## Consequences
- J.R's install builds with zero Settings edits: NX Play's Python, his detected keys for Switch packages, no keys for
  Switch 2, and the finished app filed like his other games.
- **Multi-part downloads:** Retriever never unpacks archives. A Switch 2 set must end up as a dump folder or a `.nup`
  before it is added. A split package (`.nsp` parts) isn't something nxnative reads either, so it needs joining
  first. Unpacking or joining is J.R's step, outside the app.
- Not verified until the first real run: whether a full build succeeds on his Mac (Xcode, .NET and other toolchain
  pieces are nxnative's own requirements, which NX Play's setup installs), and how long it takes.
- nxnative's `.app.key` reuse fingerprint, written beside the output app, is moved to the Trash by cleanup like any
  other leftover. nxnative only uses it to skip unchanged steps.
