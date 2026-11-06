# ADR 0017 — One-click Windows installs: golden bottle, per-game clones, recipes

**Status:** Accepted · 2026-11-06

## Context
J.R wants a **Download** button on Steam games that aren't installed anywhere. One click should create a CrossOver
bottle for the game, apply its best-known settings, and install it. Steam sign-in is the biggest source of
friction in that flow, so the user should sign in to Steam in CrossOver **once in total**, not once per bottle.
J.R's rule: signed in to Steam in Retriever, plus CrossOver installed, plus a signed-in Steam in CrossOver,
together count as standing consent to install games into new bottles.

## Decision
- **Recipes** (`RecipeDatabase`, bundled as `BottleRecipes.json`):
  - Keyed by Steam app ID.
  - Each gives the Windows version (Windows 10 or 11), graphics backend (D3DMetal, DXMT or DXVK), sync mode
    (MSync or ESync), extra environment variables and flags, notes, and a compatibility verdict
    (`works`, `mostlyWorks`, `untested`, `antiCheatBlocked`, `broken`).
  - The file is versioned (`schemaVersion`, `databaseVersion`) and is plain JSON, so it can be extended by the
    community later. Formats newer than the build are refused.
  - It ships with seven seed titles and a sane default (Windows 10, D3DMetal, MSync, marked untested).
  - Recipes apply **per game**, because every game gets its own bottle.
- **Golden bottle:** one template bottle whose Steam is signed in. No game is ever installed into it, so clones
  stay small.
  1. **Adopt.** Retriever scans each bottle's Steam `config/loginusers.vdf` for a `MostRecent` account that
     matches the SteamID linked in Retriever. A matching bottle with no games is adopted **automatically**: under
     zero-tinker, convenience wins (ADR 0016). A matching bottle that has games installed is not adopted, because
     every clone would copy those games, and the screen explains this.
  2. **Create.** Otherwise the offer appears, in J.R's words: "Would you like to install Steam via CrossOver?…".
     Accepting it creates **"Retriever Steam"** (Windows 10), installs Steam, opens it, and waits for the user to
     sign in **once**, in Steam's own window.
- **Per-game install:**
  1. `cxbottle --clone` copies the golden bottle into "Retriever – <title>", so the Steam session carries over.
  2. The recipe is applied **after** cloning, because graphics and sync are bottle-level settings:
     `cxbottle.conf` is backed up, then `[EnvironmentVariables]` is written, and `winecfg -v` runs only for
     Windows 11 recipes.
  3. `steam.exe -applaunch <id>` starts the install, and `appmanifest_<id>.acf` is watched for progress.
  4. When it finishes, the install is recorded on the game in the same shape as branch 10 provenance, so Launch
     routes to the bottle.
- **States shown:** checking, creating the bottle, cloning, applying the recipe, installing Steam, waiting for
  sign-in, Steam needing a sign-in in this bottle, starting the download, downloading (with %), installed, and
  failed (with the reason).
- **Lost session:** Steam's session may not survive a clone (client update, expired token, Steam Guard). This is
  detected when the clone's `loginusers.vdf` no longer names the linked account, or when the download never
  starts. The screen then says **"Steam needs a sign-in in this bottle"** **once**, offers Open Steam, waits one
  more period, and stops with the reason. It never loops and never asks for credentials.
- **Gates, in order:**
  1. Only Steam games installed nowhere get the panel.
  2. A blocking verdict replaces the button with the verdict and the reason why, even if CrossOver is missing.
  3. CrossOver missing → the button says so and links CodeWeavers.
  4. Free space must cover the game (its known size, or the recipe's estimate, labelled as an estimate) plus
     2 GB for Steam.
  5. The golden bottle must be ready.
- **Credentials:** Retriever reads only the SteamID and the `MostRecent` flag from `loginusers.vdf`. It never
  asks for, reads or stores Steam credentials.
- **Steam installer:** Valve's `SteamSetup.exe` is downloaded, checked for a Windows executable header, and run
  silently with `/S`. CrossTie isn't used because it can't be scripted from the command line.
- **Seams for later slices (designed, not built):**
  - `StoreClientInstalling` and `StoreGameReference`, for Epic and GOG clients.
  - `BottlePlanning`, for a shared-bottle mode.
- **Never deletes:** a failed or cancelled install keeps its bottle and says so.

## Consequences
- **Unverified against a live CrossOver** (tests mock the CLI). Each of these is kept in one place for
  adjusting:
  - the `cxbottle --clone` syntax;
  - the `CX_GRAPHICS_BACKEND` key in `cxbottle.conf`;
  - `winecfg -v win11`;
  - Steam's silent install.
- The seed recipes are a starting point, not lab results. Their verdicts come from widely reported behaviour,
  such as anti-cheat refusing Wine-based layers.
- A Windows 11 recipe runs one extra `winecfg` step on a Windows 10 clone.
