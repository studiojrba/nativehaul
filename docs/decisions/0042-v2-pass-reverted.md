# ADR 0042 — The v2 design pass (Floema / Kriss) is reverted; its branches are kept

**Status:** Accepted · 2026-11-09 (J.R, Mon 21:18 EST: full revert)

## Context
The v2 pass was built on four stacked branches on top of the media pass, all pushed and reviewed by J.R from his
running copy:

| Branch | Tip | What it was |
|--------|-----|-------------|
| `feature/detail-case-redesign` | `3930924` | Floema-style detail page: sticky 3D game case, ordered content column (its ADR is numbered 0039 on that branch) |
| `feature/light-feel` | `0ca3084` | Light only, warm Kriss feel: frosted sidebar, pastel scene tints (ADR 0040 on that branch) |
| `feature/guided-onboarding` | `cab3179` | Kriss-style guided onboarding that types its lines and moves between screens (ADR 0040 on that branch) |
| `feature/type-and-bare-covers` | `a38148a` | One grotesque family (Inter vs SF Pro), bare covers (ADR 0041 on that branch) |

## Decision
- **Full revert:** J.R chose a full revert to the app exactly as it was before the pass. The running app is built
  from `e275e64`, the tip of `feature/igdb-media-seam` (the media pass) and the point every v2 branch was cut from.
- **What that state includes:**
  - the dark theme as before, following the macOS appearance;
  - the energy pass at Leaned in;
  - the floating sidebar;
  - F4 Home and the F5 Installed filter;
  - the original detail page and first-run sheet;
  - the rounded type and the art-coloured cover tiles.
- **Font question closed:** the Inter vs SF Pro question is moot and closed.
- **Nothing deleted, no history rewritten:** the four v2 branches stay on GitHub exactly as pushed, in case J.R
  ever wants any of it back. This record lives on `chore/revert-v2-pass`, cut from `e275e64`, with documentation
  changes only.
- **ADR numbering:** this ADR is numbered 0042 so it never collides with the 0039–0041 records on the retained
  branches.

## Consequences
- **The media pass stays:** trailers, titledb screenshots, the IGDB seam and the no-crop slideshows sit below the
  v2 pass, so they are unaffected.
- **Bringing v2 back:** restoring any of it means merging or rebasing a retained branch. Its tests, renders and
  ADRs travel with it.
- **Leftover settings are harmless:** the reverted build ignores the v2 settings already written on J.R's Mac
  (the tour's progress key). The bundled Inter font exists only on the v2 branch.
