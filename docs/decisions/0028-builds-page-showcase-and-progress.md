# ADR 0028 — Builds page: showcase above the job, segmented progress above the log

**Status:** Accepted · 2026-11-07 · J.R design direction (00:37–00:38 EST)

## Context
J.R wants the Builds page's job detail to feel alive while a build runs: the game's own screenshots above it, and a
progress bar that shows where the build actually is instead of only a scrolling raw log.

## Decision
- **Layout:** the job detail takes **two thirds** of the page width (`DesignTokens.Builds.detailShare`) and the
  queue keeps a third. Both are fixed parents in a `GeometryReader` with a hairline between them; the former
  draggable splitter is gone. This keeps the QA Finding #2 contract: a layout guard measures the job detail at its
  two-thirds share of 900, 1100 and 1280 px windows (long title, showcase and progress included), and nothing
  overflows.
- **Showcase (`BuildShowcase`, `BuildShowcaseView`):**
  - **Where the art comes from:** the art the existing metadata pipeline already cached for the matching library game
    (Steam store screenshots for a Steam App ID, SteamGridDB with a key). The game is matched by Switch title ID, then
    by name. Nothing new is fetched.
  - **What shows:** with screenshots, a slideshow. Without screenshots, the hero/banner as one still. **Without any
    art, nothing**: no empty box.
  - **Behaviour:** a fixed 16:9 area with the `lg` radius and a hairline, a quiet surface placeholder, and images
    decoded off the main thread (downscaled), so there is no layout shift and the build UI never waits. It advances
    every **3 s** with a **0.8 s crossfade** and loops. It pauses while hovered and has no gestures, so it never takes
    clicks meant for the build controls. **Reduce Motion:** first image only, still.
- **Segmented progress (`BuildProgress`, `BuildProgressBar`):**
  - The stage state is parsed from the runner's lines into `BuildJob.progress` as each line arrives, as structured
    state.
  - **Formats** (read from nxnative's build script; its piped output uses "lines" mode):
    - stage start: `[hh:mm:ss] [k/n] stage · step …`;
    - progress beat: `[hh:mm:ss] [k/n] stage · step: 91%, 22.2/~24.4 GB, 1:00 · ETA 0:06`;
    - stage end: `[hh:mm:ss] ✓|⚠|✗ [k/n] stage (m:ss)`.
    The clock is optional, and a bare `91%, …` line counts for the current stage.
  - **Overall** = (completed stages + current stage fraction) / total, floored to a whole percent, and **never runs
    backwards**: not within a stage, and not across a re-plan. When the engine adds a stage (5 → 6), the bar
    re-segments to the new total while the displayed percent holds.
  - **The bar:** one track split into a segment per stage. Finished segments are full accent, the current one fills
    with its fraction, and upcoming ones stay on the track colour. Beside it: the stage name and "k of n", the overall
    percent (mono, accent), and elapsed · ETA (mono).
  - **No stage markers:** an indeterminate bar rather than a stuck 0%. **Reduce Motion:** values land without
    animation.
  - It sits above the raw log, which is unchanged.

## Consequences
- **When the slideshow appears:** only for builds whose game is in the library with cached official art. A first-time
  Switch build of a game Retriever hasn't seen shows no slideshow, by design (no empty box).
- **Renders:** the job pane at 900, 1100 and 1280 (dark and light), mid-build, with stand-in screenshots, were
  inspected; a set is in `docs/design/builds-page/`. To capture the async images, the offscreen renderer gained a
  path that waits with `Task.sleep`, because blocking the main thread kept the view's load task from running.
