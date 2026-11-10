# Releasing nativehaul

The pipeline is `scripts/release.sh` (ADR 0051). It archives a Release build, then:
1. signs it with Developer ID and the hardened runtime, with secure timestamps;
2. notarizes and staples the app;
3. builds `nativehaul-<version>.dmg` (the app plus an Applications link), then signs, notarizes and staples it;
4. checks both with Gatekeeper;
5. writes a Sparkle `appcast.xml` signed with the update key, using that version's CHANGELOG section as the notes.

Output goes to `build/release/<version>/`, which git ignores.

## One-time setup (release Mac)
- **Developer ID Application certificate:** in the login Keychain. It's already on J.R's Mac (team `N8FMX72NM8`).
- **Notarization credentials** (J.R runs this himself; it asks for an app-specific password from appleid.apple.com):
  ```bash
  xcrun notarytool store-credentials nativehaul-notary --apple-id <apple-id> --team-id N8FMX72NM8
  ```
- **Sparkle update key:** already generated in the login Keychain (`generate_keys --account nativehaul`).
  - Back it up once, offline: `generate_keys --account nativehaul -x <file>`. Losing it means existing installs can't
    accept updates.
  - The first release asks for Keychain access to it. Choose **Always Allow**.

## Cutting a release
1. Pick the version by semantic versioning:
   - **PATCH** for fixes;
   - **MINOR** for new features that keep existing behaviour;
   - **MAJOR** for breaking changes, such as a data reset or a dropped macOS version.
2. In `project.yml`, set `MARKETING_VERSION` to that version. Raise `CURRENT_PROJECT_VERSION` by one: Sparkle
   compares this integer, so it must grow with every release.
3. In `CHANGELOG.md`, turn `## [x.y.z] - Unreleased` into `## [x.y.z] - YYYY-MM-DD`, and add the link line at the
   bottom.
4. Run `./scripts/build.sh` (tests) and `./scripts/lint.sh`. Commit, and merge into `production`.
5. Run `./scripts/release.sh` and check its output. Then run `./scripts/release.sh --publish`. It asks before it
   tags `v<version>` and creates the GitHub release with the DMG, `appcast.xml` and `SHA256SUMS`.

`./scripts/release.sh --skip-notarize` runs everything except notarization, for local checks. Its DMG must never be
published.

## Release checks
Run these on every release. A box is ticked only when it was actually done.

### Clean-machine install
Use a Mac, a fresh macOS user or a VM that has never had nativehaul.
- [ ] Download the DMG from the GitHub release in Safari, so it carries quarantine like a real download.
- [ ] Open it: it mounts without warnings, and shows nativehaul and the Applications link.
- [ ] Drag nativehaul to Applications and open it. Gatekeeper opens it with no "unidentified developer" or "damaged"
      dialog; at most the standard "downloaded from the Internet" confirmation appears.
- [ ] The first-run welcome appears. Get started adopts what's on disk (or shows an empty shelf), and nothing asks
      for an account or a permission beyond folder picks.
- [ ] Settings → Updates shows the version, and "Check for Updates…" says it's up to date.

### Upgrade from the previous build
- [ ] With the previous version installed and its library populated, quit it.
- [ ] Install the new version over it (drag-replace from the DMG, or through Sparkle once a previous release has it).
- [ ] The library, playtime, settings and pasted keys all survive.
- [ ] Keys pasted under a development-signed build make macOS ask once for Keychain access, because the signer
      changes from Apple Development to Developer ID. Choose Always Allow. From the first Developer ID release on,
      there's no prompt.

### Sparkle end to end (from the second release on)
- [ ] Run the previous release, then choose Check for Updates…: it offers the new version with its notes, installs
      it, and relaunches.
