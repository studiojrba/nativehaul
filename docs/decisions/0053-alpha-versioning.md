# ADR 0053 — Public versions start at 0.1.0 (the alpha line)

**Status:** Accepted · 2026-11-13 (J.R, Nov 12: the publish-at-1.0 gate is scrapped)

## Context
1.0.0 (build 2) was built, notarized and installed on J.R's Mac, but never published. On Nov 12 J.R decided that the
public line starts lower: 1.0 should mean the full vision (couch mode complete, the zero-tinker clean-machine test
passed, the polish list closed), and everything before it is an alpha people can already use.

## Decision
- **Marketing version 0.1.0** for the first public release. 0.1 to 1.0 is the alpha period.
  - New capability → next 0.x. Fixes batch into the next 0.x. A fix that can't wait → 0.x.1.
- **Build numbers keep climbing:** 0.1.0 is build **3**. Build 2 belongs to the private 1.0.0 and is never reused.
  Sparkle compares `CFBundleVersion`, so a 1.0.0 (2) install sees 0.1.0 (3) as newer.
- **The alpha is not marked a GitHub pre-release.** Sparkle's feed reads `releases/latest/download/`, and GitHub's
  "latest" skips pre-releases, so a pre-release would never reach anyone through updates.
- **Both of J.R's Macs** take one clean 0.1.0 install (drag-replace from the DMG) to join the alpha line.
- 0.1.0 ships desktop **and** couch mode, the redesigned UI in both appearances, the n. icon and audio.

## Consequences
- `project.yml` reads `MARKETING_VERSION: "0.1.0"`, `CURRENT_PROJECT_VERSION: "3"`; the changelog's first section is
  `## [0.1.0]`.
- The private 1.0.0 entry is folded into 0.1.0's notes; there was never a public 1.0.0.
- `docs/RELEASING.md` gates are the alpha gates; the 1.0 gates move to "before 1.0".
- ADR 0051's numbering rules still hold (semver, integer build that always grows).
