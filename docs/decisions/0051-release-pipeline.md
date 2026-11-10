# ADR 0051 — Semantic versioning, changelog and the release pipeline

**Status:** Accepted · 2026-11-10 (J.R release track: Developer ID signing, notarization, stapled DMG, semver,
changelog, install and upgrade tests)

## Context
1.0 is distributed as a DMG outside the App Store. It must open cleanly through Gatekeeper, update through Sparkle
(ADR 0050), and say what changed in each version.

## Decision
- **Versions:** `MARKETING_VERSION` follows semantic versioning (MAJOR.MINOR.PATCH). `CURRENT_PROJECT_VERSION` is an
  integer that grows with every release, because Sparkle compares it. 1.0 is `1.0.0`, build `2`; the development
  builds before it were `0.1.0`, build `1`.
- **Changelog:** `CHANGELOG.md` follows Keep a Changelog. The section for a version becomes its GitHub release notes
  and its Sparkle notes. `ReleasePolicyTests` fails if the current version has no section or the build number isn't
  an integer.
- **Pipeline:** `scripts/release.sh` runs archive → Developer ID export (hardened runtime, secure timestamps) → app
  notarized and stapled → signed DMG notarized and stapled → Gatekeeper check → signed appcast.
  - Publishing (tag plus GitHub release) is a separate `--publish` flag, and it asks first.
  - No team ID, Apple ID or password is in the repo. The script finds the Developer ID identity in the Keychain and
    uses the `nativehaul-notary` notarytool profile.
- **Canonical build (ADR 0029):** release output lives in `build/release/<version>/` and is not launched there.
  The Debug app in DerivedData remains the one copy to run during development.
- **Release checks** are a checklist in `docs/RELEASING.md`: clean-machine install, upgrade from the previous
  build, and Sparkle end to end. They need a notarized DMG and a clean Mac or VM, so they are run by hand on every
  release.

## Consequences
- Developer builds are signed with Apple Development; releases are signed with Developer ID. Keys pasted under a
  developer build trigger one Keychain prompt in the first release.
- Until J.R stores notarization credentials, only `--skip-notarize` builds are possible: signed, but rejected by
  Gatekeeper as unnotarized.
