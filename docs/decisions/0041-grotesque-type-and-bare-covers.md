# ADR 0041 — One neutral grotesque for all type; covers sit bare

**Status:** Accepted for J.R's look · 2026-11-09 (J.R, Mon 20:48 EST, reacting to the light build). The family is
**not locked**: J.R picks Inter or SF Pro from the Home renders in `docs/design/type-choice/`.

## Context
With the light build in front of him, J.R said:
- Large type is fine, but the rounded font read as too round and childish.
- The all-mono data treatment should go.
- The thick art-coloured frames around game covers (Jump Back In, the library grids) should come off.

## Decision: type
- **One clean neutral grotesque family for everything, with no rounded variants anywhere** (display, labels,
  buttons).
  - Every type token now comes from `TypeFace`.
  - A source guard (`TypeAndCoverTests`) fails on any `design: .rounded`, `design: .monospaced`, `.fontDesign(` or
    monospaced system font in the app.
- **Candidates:**
  - **Inter** (first pick): bundled as `InterVariable.ttf` (v4.1, SIL Open Font License, licence file alongside),
    registered for the process at launch.
  - **SF Pro**, the standard design (the alternative).

  `TypeFace.family` switches between them in one place. It defaults to Inter until J.R picks, and falls back to SF
  Pro if Inter can't be loaded.
- **Headlines:**
  - weight down to **semibold** (they were black and heavy);
  - **tighter tracking**, −0.03 em of the size, so bigger type tracks tighter (`TypeFace.headlineTracking`);
  - sizes unchanged, still set by the dial.
- **Figures:** the mono face is gone. Times, sizes and counts use the same sans with **tabular numbers**
  (`Typography.figures`, `.figuresSmall`, `.statValue`, `.rank`).
- **The game case's spine** is drawn in the same family, semibold.

## Decision: bare covers
- **Frames removed:** `CoverCard` loses its art-coloured field, the inset around the art and the hairline frame.
  It is used by Jump Back In, Recently Added and the library grids.
- **What remains:** the cover is the artwork itself with its corner radius, and the caption below is unchanged.
  There is no replacement outline, mat or frame.
- **Selection:** a selected card still gets its selection ring. That is state, not a frame.
- **Hover:** the card lifts and the cover grows slightly, as the one hover gesture.
- **Tokens removed:** `EnergyLevel.tileFieldOpacity`, `tileInset` and `ArtTint.fieldFalloff`.

## Consequences
- **Locking the family** is a one-line change in `TypeFace`. If J.R picks SF Pro, the bundled Inter file can be
  removed.
- **Older renders are stale:** earlier renders show the rounded type and framed tiles.
