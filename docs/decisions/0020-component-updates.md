# ADR 0020 — Managed components and update badges (Obtainium-style), per source

**Status:** Accepted · 2026-11-06

## Context
J.R wants emulator apps to be one click to install and easy to keep current, without the app updating things
behind the user's back. His rules: **auto-update is the user's choice and defaults to off**; the app notifies and
the user clicks; **badges over automation**. Games need update badges too. Each source updates differently, so the
badges are per source.

## Decision
- **Component catalog:** `ComponentCatalog.json`, versioned like the recipe database so it can be extended by the
  community. The seeds are the emulators from ADR 0019. Each entry has:
  - a source: either a GitHub `owner/repo` plus a macOS asset regex (melonDS `.zip`, PCSX2 `.tar.xz`), or a
    **pinned official URL** with its version (RetroArch and Dolphin, whose GitHub releases don't carry the Mac
    build);
  - an install method (`dmg`, `zip` or `tar`);
  - the destination `~/Applications`, which needs no admin prompt.
- **One-click setup:** any emulator that isn't installed shows **Install** in Settings → Emulators, which is
  also onboarding's Emulators step. The steps are:
  1. Download from the catalog's official source **only**.
  2. Check the published SHA-256 when there is one: GitHub's asset `digest` or the catalog's `sha256`. A
     mismatch stops everything before unpacking.
  3. Unpack: mount a disk image read-only, or `ditto`/`tar` an archive.
  4. Ask macOS about the signature (`codesign --verify`, `codesign -dv` for the team, `spctl --assess` for
     notarization).
  5. **Show the user** "Signed by <team>, notarized" or "Unsigned — macOS will ask you to confirm when it first
     opens".
  6. Install on a second click.

  Installing copies the app into place, moves any replaced copy to the Trash, and **adds the quarantine flag**
  (`com.apple.quarantine`), so Gatekeeper still checks the app on first launch. Quarantine is never stripped,
  and Gatekeeper is never bypassed. After an install, the emulator becomes the route for every system that had
  no installed emulator (zero-tinker).
- **Update checks:**
  - GitHub's latest-release API, or the catalog's pinned version, compared with the installed app's
    `CFBundleShortVersionString`.
  - At most once a day (cached), and only from the app's launch upkeep or a **Check Now** click. There is no
    background daemon.
  - This covers Retriever-installed copies **and** copies the user installed themselves. For the user's own
    copies Retriever only observes and offers: "Update available", then "Manage and Update". It asks before
    taking a copy over.
- **Auto-update:**
  - "Automatically update components" defaults to **off**, and each component can be opted in separately.
  - Even when opted in, an unattended update installs only if macOS reports it **notarized by the same team** as
    the installed copy. Anything else waits for a click.
  - Every update is one click from its badge.
- **Surfaces (data layer plus simple hooks; J.R designs the visuals later):** Settings → Updates (current →
  latest, Check Now, the global switch, per-component switches), Install / Update badges on emulator rows, and
  game badges on the details rail.
- **Game update badges, per source:**
  1. **Steam (Mac and CrossOver bottles alike):** Steam does the updating. A bottle's Steam is a full Steam client
     and updates on the same terms, whenever it runs. Retriever only displays a state read from the appmanifest
     `StateFlags`: update pending (UpdateRequired, UpdateStarted or UpdatePaused) or updating with a percentage
     (Downloading or UpdateRunning). Launching through that Steam is the update path. Retriever never updates a
     game.
     - **`ISteamApps/UpToDateCheck` was judged not feasible.** It takes the version from a game's `steam.inf`,
       not the appmanifest's `buildid`, so it can't be answered reliably for client installs. A bottle whose
       Steam hasn't run lately therefore shows its last-known state. The badge provider is the seam for adding a
       freshness check later.
  2. **Switch ports:** **detection only.** Retriever never downloads game files. A port's built version (title
     ID and version recorded by the nxnative build; `TitleInfo` gains an optional `version`) is compared with
     `SwitchTitleVersions.json`, a community-maintained dataset keyed by title ID that ships empty. When it's
     behind, the badge reads J.R's copy: **"An update is available! Please refer to your original source for
     update files."**
     - Bonus seam, not built: a folder scan could notice a newer update file next to a port and offer a rebuild
       through the existing builds flow.
  3. **Emulated ROMs:** static files, so no badges and no states.
- **Retriever self-update:** seam only. Retriever's own GitHub releases are checked for a newer tag, and a
  notify-only badge links to the release page. Real in-app updating (Sparkle) waits for signed release builds.
- **Hard lines:**
  - Retriever never downloads ROMs, BIOS files or firmware, and bundles nothing.
  - A BIOS is requested with the **"Please provide your ___"** prompt (ADR 0019), and the user's own file is
    placed where the emulator expects it. What's prohibited is the app obtaining the file.
  - Nothing downloads without a click unless the user opted that component into auto-update.

## Consequences
- **Pinned URLs and asset patterns are unverified live.** No download was made from this machine. The pinned
  RetroArch and Dolphin URLs must be checked by whoever maintains the catalog. A wrong URL fails with a plain
  error and installs nothing.
- **Staging is never cleaned:** staged downloads live in the user's temporary folder, which macOS clears on its
  own. Retriever deletes nothing (enforced by `SafetyPolicyTests`).
- **Switch badges need versions:** they appear only once a port has a recorded version and the dataset has an
  entry for its title.
