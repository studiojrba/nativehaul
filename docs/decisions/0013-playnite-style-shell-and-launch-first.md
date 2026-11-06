# ADR 0013 — Playnite-style shell; launching first

**Status:** Accepted · 2026-11-06

## Context
J.R's reference is his Windows Playnite setup. He wants an icon rail that expands on hover, a poster grid as the
default view (keeping the text under each card), and a three-column details screen. Launching is the priority.

## Decision
- **Shell:**
  - `NavigationSplitView` is replaced by a `NavigationStack` with an `IconRailView` overlaid on the leading edge.
  - The rail is icon-only at `Rail.collapsedWidth` and expands to labels and counts on hover. It floats over the
    content, so the grid never reflows.
- **Grid:** posters keep the title, a caption (platform plus per-source playtime) and the status tag. The context
  menu offers every launch route.
- **Details (click only):**
  - `GameQuickList` on the left.
  - In the centre: `HeroMediaView` (hero image, then cover, then a placeholder), genre chips, description, then the
    existing sections (series, playtime, sessions, Steam provenance, achievements, guides).
  - `GameDetailRail` on the right: cover, a big `LaunchButton` (primary action plus a menu of alternatives),
    Manage…, HLTB chips (Main Story / Main Story+ / Completionist, labelled "HLTB estimate") and `GameInfoList`
    (Status, Install Size, Time Played, Developer, Source, Release Date, Date Added, Platform, Tags).
- **Formatting** lives in `GameInfoBuilder` and `HLTBChip`, not in views. "Time Played" lists each source
  separately and never shows a merged total.
- **Launching** uses `LaunchPlanner` (ADR 0012):
  - `.app` launches go through NSWorkspace and start the watcher, so sessions are recorded as MacTracked.
  - Steam launches follow provenance.
  - With no target, the button is disabled and shows the reason.
- **New optional metadata:** `developer`, `genres`, `tags`, `heroImagePath` on `Game` and `GameRecord`, merged by
  `GameMerger`. Install size comes from Steam manifests or a measured `.app` bundle.
- Every new value is a token (`DesignTokens.Rail`, `DesignTokens.Details`, `Typography.launch`). The Figma pass
  re-skins without touching logic.

## Consequences
- Status, hours and artwork editing moved into the Manage sheet, along with the tracked app and HLTB entry.
- Hero images and genres are set by hand or by import until a metadata provider exists.
