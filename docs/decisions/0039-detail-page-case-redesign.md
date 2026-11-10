# ADR 0039 — Game detail page: sticky 3D case and one ordered column

**Status:** Accepted for J.R's look · 2026-11-09 (spec confirmed by J.R, Mon 19:45 EST). Not to merge without his
eyeball (renders in `docs/design/detail-redesign/`).

## Context
J.R sent screenshots of the Floema product page (the Trailhead kiosk panel) as the structural reference. What
matters is the layout pattern, not the product: a sticky visual panel on the left, a calm scrolling column of
content on the right, and a thin divider between them. A second reference (Kriss, for feel and onboarding) belongs
to the next pass and gets its own ADR.

## Decision
**Two zones** inside the existing shell. The floating sidebar is untouched. The old three columns (quick list,
centre, info rail) are gone; Manage… moves to the toolbar.

### Left: the sticky case panel (`GameCasePanel`, 360 pt, never scrolls)
- **3D case:** a SceneKit `SCNBox` (`GameCaseScene`), driven by `GameCaseController` and the pure `CaseMotion`.
  - Drag turns it. A flick spins on with inertia, then eases back to a slight resting angle (0.42 rad yaw,
    0.08 rad tilt) that shows the spine.
  - While idle it sways gently.
  - Plus and minus zoom buttons sit at the panel's edge and move the camera.
  - Frames run only while something moves, and stop when the page is hidden.
- **Faces:**
  - front = the cover;
  - spine = the title in heavy type on the case colour (Retriever caches no logo art yet, so no spine uses one);
  - back = the hero, else the first screenshot;
  - edges = the art's sampled tint (`ArtworkTint`), darkened.
- **One case proportion for every game** (a keep case, 135 × 190 × 14 mm), whatever the platform: a deliberate
  physical-media shelf fiction.
- **The one crop:** the front and back are trimmed to the face like a printed box (`AspectFillCrop`). This is the
  only exception to ADR 0038's no-crop rule, which still governs every screenshot and trailer.
- **No cover art:** the panel shows the plain media treatment instead of a case (the hero, else a placeholder,
  fitted whole).
- **Reduce Motion:** no idle sway and no inertia. Dragging still turns the case, and it returns to rest when
  released.
- **Offscreen renders:** a live Metal view can't be captured, so render tests set `gameCaseRendersStill`, and the
  panel shows `GameCaseScene.snapshot` (the same scene, rendered by `SCNRenderer`).

### Right: one scrolling column, in this exact order
1. **Title:** big and heavy, at the dial position's display size (`EnergyLevel.display`).
2. **Short description** in the large subheading style (`DetailColumn.lead`, 21 pt). `DetailDescription` uses
   the text as it is when it fits 280 characters (a short source: Steam's short description, IGDB's summary).
   Otherwise it uses the opening whole sentences that fit.
3. **Buttons row:** Play Now (the existing launch button, relabelled) and the status control side by side. The
   CrossOver install panel and the update badge sit under them when they apply.
4. **Slideshow:** the media set from ADR 0038, trailer first, then official screenshots, fitted whole. The hero
   and cover are left out because they are printed on the case. It is hidden when there is neither a trailer nor
   a screenshot.
5. **HLTB bar** (`HLTBBar`):
   - Main Story, Main Story+ and Completionist are marked on one track, labelled "HLTB estimate".
   - The player's time fills it from the largest single real source.
   - Every real source is listed beside it, never added together (ADR 0006).
   - With no estimate, only the player's time shows.
6. **Full description:** only when it is longer than the short text used at item 2.
7. **Specs table** (`GameSpecsTable`): a small label on the left, the value on the right, hairlines between.
   - Rows: release date, genres, developer, features (Steam categories), platform, source, install size.
   - A row appears only when its data exists, so there are no empty rows. Retriever stores no publisher, so there
     is no publisher row.
   - Session history follows, then the sections that had no slot in the spec (series, Steam provenance and
     achievements, guides), so nothing is lost.

### Removed
- The detail quick list and the info rail, and their views and tokens.
- The art-glow wash behind the old hero: it drew as a hard-edged block in the narrower column. Per-scene tinting
  comes back in the light pass.

## Consequences
- **Moving between games:** the detail page no longer has its own game switcher. You move between games from the
  library or the sidebar.
- **Idle sway costs frames:** the case renders at 60 fps while the page is visible (not under Reduce Motion).
- **Not built (J.R: future direction only):** a shelf-style library view reusing this case model.
