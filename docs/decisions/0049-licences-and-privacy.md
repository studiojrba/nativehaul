# ADR 0049 — Licences, notices and privacy for 1.0

**Status:** Accepted · 2026-11-10 (J.R release track: MIT licence, third-party notices, licence audit, no telemetry)

## Context
1.0 ships publicly as a notarized DMG. It needs a clear licence, credit for everything it ships or works with, proof
that nothing copyleft is bundled, and an honest privacy statement.

## Decision
- **Licence:** MIT, © 2026 Studio Jrba inc. (`LICENSE`). The Info.plist copyright says the same.
- **Notices:** `THIRD_PARTY_NOTICES.md` lists everything shipped and everything used but not shipped (nxnative,
  emulators, data sources, services). `LICENSE` and the notices are copied into the app's Resources.
- **Audit:** `docs/LICENSE_AUDIT.md` records the method and result. Nothing GPL is bundled; emulators are external
  launches only.
- **Privacy:** `docs/PRIVACY.md` lists every host the app contacts or links to, when, and what is sent. There is no
  telemetry of any kind.
- **Enforcement:** `ReleasePolicyTests` fails when:
  - source code names a host the privacy policy doesn't list;
  - the app doesn't ship its licence and notices;
  - the app bundles a framework the audit hasn't approved.

## Consequences
- Adding a dependency or a network host is a deliberate, documented act, enforced by tests.
