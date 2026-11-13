# ADR 0056 — Detail and Builds for 0.1.0

**Status:** Accepted · 2026-11-13 (0.1.0 overnight run, Phase 3; spec `nativehaul-swift-spec.md` §1.8, §1.11, §2.5,
§3.3, §3.4, §6). Items marked *pending* await J.R's approval.

## Context
0.1.0 replaces the three-column Playnite-style details page and the NXNative dashboard with the Make design: Detail
shows the game case as an object on a sticky column beside a scrolling column, and Builds shows the queue as "In the
oven" beside the selected build on its game's wash. The Make code uses mock data (taglines, players, player app
versions, a 300ms fake progress timer). The app must use the real library and the real build engine.

## Decision
### Detail (`Features/Detail`)
- `DetailViewModel` (MVVM) over the game, its `GameLaunchViewModel` and the older `GameDetailViewModel`. The copy and
  specs come from `DetailFacts`, a pure builder. **Rows without a real value are left out**: no tagline (nothing
  supplies one), no Players (no field). Playtime comes from the **single biggest source**. It is labelled "· self-reported" when not
  Mac-tracked. HLTB shows only as its own "HLTB estimate" row.
- **Platform** says the real thing: "Nintendo Switch port", the emulated system ("Super NES") or "Mac". **Plays with** says
  "Native Mac app" for ports and Mac games and "Emulated · {system}" for ROMs. Emulator apps are never named.
- **The case** is a real six-face box: each face is laid out at the box centre and projected with one `CATransform3D`
  (`CaseProjection`: CSS-convention rotations plus `perspective: 1800`) through `projectionEffect`. Faces that turn
  away are culled with a normal-to-eye test. `GameCaseBody` is `Animatable` on (yaw, pitch), so the faces swap at the
  right moment mid-turn. The pose maths is pure and tested (`CaseSpin`): drag 0.45°/pt yaw and −0.2°/pt pitch within
  ±25°, hover parallax, settle to rest + 180k over 1100ms, turn over, sheen angle and floor width.
- **Case colours**: Switch ports keep the approved red. Emulated, Mac and other games get a charcoal case (the `bezel`
  family) of the same shape, so the red stays a Switch thing. The mark is the design's generic `CaseMark`, drawn by
  nativehaul, never a console logo. The band label is "Game Card" on Switch cases and the system name (or "Mac") on the
  others. The back has the short title (instead of a tagline), up to four real screenshots, the description, "{studio} ·
  {year}" and a barcode drawn from the title ID (else the library ID).
- **Favourite**: a persisted `Game.isFavorite: Bool = false`. This is an additive, defaulted attribute, so SwiftData's
  lightweight migration handles it (same pattern as `hltbID` and `retroAchievementsGameID`). It is exported and imported
  in the library archive (optional field) and kept when duplicates merge.
- **Show in Finder** uses a new `FileRevealing` service (`WorkspaceFileRevealer` / `RecordingFileRevealer`). It reveals
  the app, else the ROM, and reads nothing.
- **Play** goes through the shell (`ShellViewModel.play(_:option:)`) for the launch overlay and the error surface.
  Detail still shows every launch state from its `GameLaunchViewModel`: "via …", the unavailable reason, the official
  page of a missing app, the one "Please provide your ___" prompt, and errors. Other routes sit in a small menu beside
  Play.
- **The build link** appears only from real state (a job for the title, or a known newer version). It opens Builds
  focused on that title (`ShellViewModel.openBuilds(focusing:)`).
- **Screenshots**: the designed 16:9 + two 4:3 grid of the game's cached media. The heading is **"Screenshots"**, not
  "From your last session", because these are not the user's own captures (*pending*).
- **Editorial note**: only once there is playtime. One evening reads "one long evening".
- **Nothing is lost**: everything the old page had and the design doesn't sits in "More about this game" at the end:
  Manage… (status, self-reported hours, artwork, metadata, tracked app, HLTB entry), the update notice, playtime per
  source, HLTB chips, sessions, series, RetroAchievements, guides (link-out only), the full info list and the trailer.
  The Manage sheet is unchanged, so Phase 5 can add "Open windowed" there.

### Builds (`Features/NXNative`)
- **Six fixed stages** (`PipelineStage`). `PipelineStageMapper` is a pure mapper from the real queue state:
  - queued → Found; pre-build checks → Prepare.
  - Engine steps (`[k/n] name`) are placed by name: extract/unpack → Prepare; verify/check/hash → Verify;
    rewrite/patch/heap/nso → Patch; shaders, then package/pack/sign → Shaders. Unknown names fall back to their position
    among the engine's steps, spread over Prepare…Shaders.
  - Built → Ready.
  - A failed or stopped build keeps the stage it reached and is flagged.
- **It never runs backwards**: the queue stores each job's position (`BuildJob.pipeline`) and advances it on every
  update with a high-water mark. Queuing a job again starts it from Found.
- **Overall percent** = ((stage + inStage)/5) × 100, floored. A running build is capped at 99% until it is really Ready.
  Waiting for the tidy-up approval reads "Needs your OK".
- **No Pause**: the engine has none. The header shows the queue's real controls instead: **Start building** when
  something is queued and the queue is idle, **Stop building** (real cancel) while it runs, and "Ready to play" once
  built.
- **Time left** is the engine's own ETA, and its card is left out when there is none. **Plays with** is "Native Mac
  app" (a built port is a native app; there is no player version to show).
- **Slideshow** (`BuildShowcaseView`, rewritten): the build's game's cached screenshots (else hero), each contain-fitted
  to its own shape in a surface frame, crossfading over 1200ms every 3.6s, with quiet dots.
- **Nothing is lost**: Add a build (folder-first sheet) and **Tools** (Known Issues and Fixes…, Choose the Build
  Engine…, Look for the Engine Again) sit by the list. The engine-not-found "Choose…" banner sits above the build, and
  the switched-off state still offers to turn it on. Under each build: provide prod.keys, the tidy-up plan (approve or
  skip), known issues the log matches, the pre-build checks, the build log, Re-check, Put Back in the Queue and Remove.
  Troubleshooting (with its audit log) is unchanged.

### Design system
New tokens (`ShellLayout.Detail`, `.GameCase`, `.Builds`, `CaseColors`) and components (`CaseMark`,
`FavoriteToggleButton`, `StatusDot`, `UnderlinedLinkButton`, `SegmentedStageBar` + `StageSegment`, `SlideDots`,
`StatCard`). Accent use stays inside the design system.

## Consequences
- The old `GameDetailView`, its rail and quick list, `ArtGlowBackground`, `LaunchButton`, `PlayButtonStyle`, the NXNative
  dashboard, `BuildJobDetailView`, `BuildJobRow` and `BuildProgressBar` are gone.
- The NSView bitmap-cache renders used by the render tests cannot draw 3D layer transforms. The case was checked with
  `ImageRenderer` instead. Feel (drag, settle, hover) is unverified on hardware.
- Convenience wins (ADR 0016): Detail and Builds work fully on defaults. Every tool is one click away, never a setup
  step.
