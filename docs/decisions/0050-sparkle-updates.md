# ADR 0050 — App updates through Sparkle

**Status:** Accepted · 2026-11-10 (J.R release track: "Sparkle for updates")

## Context
1.0 ships outside the App Store as a notarized DMG, so the app has to update itself. The notify-only check against
GitHub releases (ADR 0020) only told the user to go and download a new version.

## Decision
- **Sparkle 2.10.1**, pinned to an exact version through SwiftPM, wrapped by `AppUpdating`:
  - live: `SparkleAppUpdater` (Sparkle's standard updater and its own windows);
  - mock: `MockAppUpdater`.
  The test host never starts it, because the live environment isn't built under tests.
- **Feed:** `https://github.com/studiojrba/nativehaul/releases/latest/download/appcast.xml`. Each GitHub release
  carries the DMG and the appcast, so "latest" always points at the newest feed. No server of our own is needed.
- **Signing:** every update must carry an EdDSA signature that matches `SUPublicEDKey`, as well as the Developer ID
  signature.
  - The private key was generated on J.R's Mac with Sparkle's `generate_keys --account nativehaul`. It lives only in
    his login Keychain and never in the repo.
  - J.R should export a backup once (`generate_keys --account nativehaul -x <file>`) and store it offline. Losing it
    means existing installs cannot accept updates.
- **Defaults, with convenience winning (ADR 0016):**
  - automatic checks are on, daily;
  - installing always asks (`SUAutomaticallyUpdate` is false; Sparkle's dialog lets the user opt in);
  - system profiling is off.
  Settings → Updates has the switch, the version and "Check for Updates…", which also sits in the app menu under
  About.
- **Removed:** the GitHub-API "newer nativehaul release" check in `ComponentUpdateService`. Sparkle owns app
  updates; the component service still checks emulator releases.
- **Privacy:** an update check sends no profile; `docs/PRIVACY.md` has the details.

## Consequences
- `Sparkle.framework` is the only bundled third-party code. Its full licence is in `THIRD_PARTY_NOTICES.md`, and
  `ReleasePolicyTests` allows exactly this framework.
- Releases must publish `appcast.xml` next to the DMG (see `scripts/release.sh`, ADR 0051).
