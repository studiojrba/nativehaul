# nativehaul — Project Rules

nativehaul is a native macOS shelf for Switch ports and emulated games (1.0 scope, ADR 0046): it adopts what is already
on disk (existing nxnative builds, ROM folders) with zero rebuilding, launches through the owning app, and includes an
on-by-default Switch build pipeline (driven by a **user-supplied, never-bundled** standalone nxnative).
Start with `README.md` (quickstart + where things live), then `docs/PLAN.md` and `docs/decisions/`.

## Platform & language
- Swift 6 language mode, SwiftUI, **macOS 15+**, **Apple Silicon only** (`ARCHS = arm64`).
- Strict concurrency (`SWIFT_STRICT_CONCURRENCY = complete`). No `@unchecked Sendable` without a
  comment explaining why it is safe. Prefer actors / `@MainActor` isolation over locks.
- Persistence: SwiftData. Networking: `URLSession` async/await. Tests: Swift Testing (`import Testing`).

## Project structure (strict feature folders — no orphan files)
- `project.yml` is the single source of truth for the Xcode project (XcodeGen, ADR 0003). The generated
  `nativehaul.xcodeproj` is **not** committed. Run `./scripts/bootstrap.sh` after cloning or adding files.
- `nativehaul/App/` — entry point, root view, dependency container (`AppEnvironment`).
- `nativehaul/Features/<FeatureName>/` — split into `Views/`, `ViewModels/`, `Models/`, `Services/`, `Resources/`
  (create only the subfolders a feature needs; never put files directly in the feature root).
- `nativehaul/Shared/` — cross-feature code only: `DesignSystem/`, `Networking/`, `Persistence/`, `Utilities/`.
- `nativehaulTests/` mirrors the source tree (`nativehaulTests/Features/<FeatureName>/…`).
- `docs/PLAN.md` (architecture & roadmap), `docs/PROGRESS.md` (status log), `docs/decisions/` (ADRs).
- A file that does not fit this map is a smell: find or create its proper home before committing.

## Architecture
- **MVVM**. Views are renderers of ViewModel state; ViewModels are `@MainActor @Observable`.
- **Protocol-first services** (ADR 0002): every service is a protocol (`MetadataProviding`, `SecretStore`, …)
  with a live implementation **and a mock implementation** usable in SwiftUI previews and tests.
  Inject through initialisers / `AppEnvironment`; no singletons reached from views.
- **Every view ships with a `#Preview`**, fed by mocks / in-memory SwiftData.
- **One type per file**, small focused files (SwiftLint `one_declaration_per_file`, `file_length`).
- **Doc comments** (`///`) on every type and every non-private API (DocC style).
- Record any major new decision as a numbered ADR in `docs/decisions/` (context, decision, consequences).

## Naming, style & access control
- Follow Apple's **Swift API Design Guidelines** (clarity at the point of use, fluent call sites,
  `is/has/can` for Booleans, protocols describing capabilities end in `-ing`/`-able` or describe a role).
- **Access control is `private` by default**; widen only as needed (`private` → `fileprivate` → internal).
- SwiftFormat and SwiftLint clean (`./scripts/lint.sh`); configs committed (`.swiftformat`, `.swiftlint.yml`).
  Thresholds: `file_length` 250/400, `type_body_length` 200/300, `function_body_length` 50/80;
  `force_cast`, `force_try`, `force_unwrapping` are **errors**.
- **No force unwraps**, no `try!`, no `as!`, no implicitly unwrapped optionals.
- **No magic numbers** — name constants; visual constants live in DesignTokens.

## Zero-tinker defaults (owner directive, ADR 0016)
J.R: the app should be "literally just install and play, and then view hours played, progress, and guide" — no
customizing or tinkering needed (the option is there for those who want it).
- Every headline feature delivers its full value **on defaults alone**. Settings and overrides exist, but no
  configuration, key paste or manual step may be a prerequisite for the core loop: **install → play → hours,
  progress and guide**.
- **No sign-in anywhere (J.R, ADR 0046).** No OAuth, no login windows, no identity phoning home. The only
  account-shaped features are API keys the user pastes (RetroAchievements, SteamGridDB, IGDB), kept in the Keychain,
  and the app is fully useful without any of them.
- Work that can run by itself does: adoption of existing builds and ROMs, dedupe, metadata, installed-game detection.
- When a design choice trades default convenience against configurability, **convenience wins** — say so in the
  branch's ADR.

## Features ship on (owner directive, ADR 0021)
J.R: features are on by default. Only the files a user has to provide gate a feature, and files the user already
has are **detected, not re-demanded**.
- No feature is off by default, and no page opens with "enable this in Settings". A Settings switch exists so a
  user can turn a feature **off**, and an explicit off is respected.
- Paths to user-supplied tools and files (the nxnative engine, `prod.keys`) are found by searching the usual places
  (documented in the feature's ADR). A Settings path is an override only.
- Ask for a file ("Please provide your ___") only when it exists nowhere. A missing engine is a plain missing-file
  state with a "Choose…" button, never a setup step.

## Shelf and router, never the engine (owner directive, ADR 0019)
Like the Cocoon launcher on J.R's AYN Thor: one front end, and each kind of game is run by the specialist app that
owns it. nativehaul routes; it never emulates, translates or runs games itself.
- Native `.app` (including nxnative-built Switch ports) → direct launch. Emulated ROMs → the user's emulator app.
  Every route lives in the launch planning model. Steam and CrossOver are not part of 1.0 (ADR 0046).
- Nothing that runs games is bundled: no emulators, no cores, no engines. nativehaul detects them, routes to them,
  and says honestly when one is missing (with its official page).
- **The build engine is upstream nxnative (J.R, ADR 0027).** Auto-detection finds standalone nxnative only
  (`~/Switch`, then Homebrew); a Settings path is the user's own choice. Never source the engine, or its Python
  environment, from another app's bundle or Application Support folder, and never name other front ends in UI copy,
  preflight lines or docs.

## Games launch from inside nativehaul (J.R, 2026-11-07 19:18 EST)
That is the point of the app, and it applies to QA too.
- User-flow testing launches games through nativehaul's **Play** button, never by opening the game's `.app` directly.
- A direct `.app` launch (Finder, `open`, `--no-launcher`, environment overrides) is a **diagnostic method only**.
  Whenever one is used, label it as a diagnostic in the report and in PROGRESS. Tonight's Finding #6
  `--no-launcher` run was one.
- A QA run that reaches a working game leaves it running for J.R; it is never quit as cleanup.
- While J.R is playing, don't run the test suite on his Mac: its test host is a second nativehaul that takes focus.

## User-provided files (owner directive, ADR 0019)
Anything that must come from the user's own sources — `prod.keys` for Switch builds, a console BIOS, a game's
`.nsp`/`.xci` — is asked for with **one** in-flow prompt: "Please provide your ___", a plain sentence on why, and a
file picker (`ProvideFilePrompt` / `UserFileRequest`). When the app knows where the file belongs (a BIOS folder), it
copies the user's file there, never overwriting.
- The app never sources, downloads, links to or hints at sources for these files. It asks; the user provides.
- **Protected folders (J.R, ADR 0026):** nativehaul never reads or watches a macOS-protected folder (Downloads,
  Desktop, Documents, …) by itself, and never asks for Full Disk Access. Access follows the user's pick (a picker
  may *open* in Downloads; the pick is the consent). Nothing on the launch path touches a protected folder.

## UI / UX — Figma-ready, token-driven (owner directive, ADR 0004)
Figma designs will arrive later. Until then, **structure and function beat bespoke polish**.
- Every visual value (spacing, sizes, radii, colours, fonts, opacity, durations, grid metrics) comes from
  `Shared/DesignSystem/DesignTokens` and `Theme`. **Zero hardcoded visual values in views.**
  A SwiftLint custom rule rejects numeric literals in `.padding/.frame/.cornerRadius/.spacing` outside DesignSystem.
- Keep views **compositional**: screens are assembled from small reusable components so they can be re-skinned
  from Figma by editing tokens/components only — never by touching ViewModels, services, or models.
- No business logic or formatting logic in views.
- **Never promise that games stay on top (J.R, ADR 0032).** macOS has no public way to pin another app's window, so
  no UI copy or doc says games "stay on top", "always in front" or "pinned". Promise the clean handoff (ADR 0030),
  The Accessibility assist was rejected (J.R, ADR 0032): never request Accessibility to keep games in front.

## Testing & verification
- Unit tests for all non-UI logic (models, services, engines, ViewModels).
- Run `./scripts/build.sh` (XcodeGen + xcodebuild build + test) after every feature; fix every compile error
  before moving on.

- **One canonical build output (J.R, ADR 0029):** always build into Xcode's default DerivedData for the project
  (`~/Library/Developer/Xcode/DerivedData/nativehaul-<hash>/Build/Products/Debug/nativehaul.app`), never a
  `-derivedDataPath`. Quit any instance you launch to verify, and leave none running at the end of a session.
- **J.R's working copy is the notarized release in `/Applications/nativehaul.app` (J.R, 2026-11-10).** It was
  installed from the 1.0.0 DMG and replaces the dev copy for everyday use. Dev builds in DerivedData are for tests
  and diagnostics only: never launch them as his copy, and never copy one over `/Applications/nativehaul.app`. To
  relaunch his copy, quit it politely (no game running) and `open /Applications/nativehaul.app`. It changes only by
  installing a newer notarized release build, until Sparkle updates take over after publishing.

## Name and identity (J.R, ADR 0045)
- The app is **nativehaul**, as if it had always been: GitHub `studiojrba/nativehaul`; project, scheme, targets, source
  folders and the Swift module are `nativehaul`.
- Its identity is its own: bundle ID `com.studiojrba.nativehaul`, `~/Library/Application Support/nativehaul` (everything
  the app writes, via `AppInfo.supportDirectory`), the store `nativehaul.store` inside it, the Keychain service
  `com.studiojrba.nativehaul`. Nothing reads, points at or migrates data from an earlier identity.

## Couch mode (J.R, ADR 0052, ADR 0058)
- Couch (TV) mode **mirrors the desktop** (Home with the shared hero carousel, Library, Detail, Builds, Settings, a nav
  column) at 10-foot scale under one controller focus model (`CouchNavigator`, pure and unit-tested). It lives inside
  the main window: it goes full screen over the desktop layout and hands the window back on exit. With couch off,
  desktop behaviour must not change; desktop launches use `LaunchStyle.standard`.
- Games launch full screen in couch (nxnative `DM_FULLSCREEN`, documented emulator flags) unless the game's Manage
  sheet says "Open windowed". Buttons act by physical position: the right face button selects, the bottom one goes
  back; prompts follow the connected controller, Nintendo glyphs by default.
- Controller behaviour is verified only on real hardware; say so in reports.

## Data integrity rules (product invariants)
- **Playtime sources are never silently merged.** Every figure carries a `PlaytimeSource`
  (`macTracked`, `selfReported`, `hltbEstimate`). Totals are shown per source.
- Badges are computed **only from real recorded data** — never estimates, never fabricated.
- HowLongToBeat figures are always labelled **"HLTB estimate"**.
- Series part numbers are **never renumbered**; Up Next drops completed items but keeps original numbering.

## Secrets & legal
- User-pasted API keys (RetroAchievements, SteamGridDB, IGDB) live **only in the Keychain**, and are read off the
  main thread (ADR 0044). Never in code, config, UserDefaults, logs, or git. The app works fully with none of them.
- **No telemetry** by default.
- The nxnative build engine is an **external, user-supplied tool** and is **never bundled**. Neither are
  console keys, firmware, or game files. `.gitignore` blocks common key/game file extensions.
- Troubleshooting actions must be **previewable, reversible, backup-first, and audit-logged**.
- File cleanup moves items to the **Trash** (`FileManager.trashItem`) and **never empties the Trash**.
- Guides: **link out only** to GameFAQs with full attribution. **No scraping, no embedding** of guide content.

## Git workflow
- **Never commit or push to `main`/`master`.**
- One branch per feature: `feature/<kebab-name>`; small clean commits; push to `origin`.
- **Conventional Commits** for every message: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
  (optional scope, e.g. `feat(emulation): detect RetroArch cores`).
- Unfinished work is still pushed, with a `WIP:` note in the commit body.
- Update `docs/PROGRESS.md` on every branch (built / compiles / stubbed / blocked).
