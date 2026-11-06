# Playrite — Project Rules

Playrite is a native macOS game library hub: a Playnite-style library combined with an optional
NX2Apple-style Switch build pipeline (driven by a **user-supplied, never-bundled** external engine).
Start with `README.md` (quickstart + where things live), then `docs/PLAN.md` and `docs/decisions/`.

## Platform & language
- Swift 6 language mode, SwiftUI, **macOS 15+**, **Apple Silicon only** (`ARCHS = arm64`).
- Strict concurrency (`SWIFT_STRICT_CONCURRENCY = complete`). No `@unchecked Sendable` without a
  comment explaining why it is safe. Prefer actors / `@MainActor` isolation over locks.
- Persistence: SwiftData. Networking: `URLSession` async/await. Tests: Swift Testing (`import Testing`).

## Project structure (strict feature folders — no orphan files)
- `project.yml` is the single source of truth for the Xcode project (XcodeGen, ADR 0003). The generated
  `Playrite.xcodeproj` is **not** committed. Run `./scripts/bootstrap.sh` after cloning or adding files.
- `Playrite/App/` — entry point, root view, dependency container (`AppEnvironment`).
- `Playrite/Features/<FeatureName>/` — split into `Views/`, `ViewModels/`, `Models/`, `Services/`, `Resources/`
  (create only the subfolders a feature needs; never put files directly in the feature root).
- `Playrite/Shared/` — cross-feature code only: `DesignSystem/`, `Networking/`, `Persistence/`, `Utilities/`.
- `PlayriteTests/` mirrors the source tree (`PlayriteTests/Features/<FeatureName>/…`).
- `docs/PLAN.md` (architecture & roadmap), `docs/PROGRESS.md` (status log), `docs/decisions/` (ADRs).
- A file that does not fit this map is a smell: find or create its proper home before committing.

## Architecture
- **MVVM**. Views are renderers of ViewModel state; ViewModels are `@MainActor @Observable`.
- **Protocol-first services** (ADR 0002): every service is a protocol (`SteamClientProtocol`, `SecretStore`, …)
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
- The only allowed prerequisites are credentials only the user can provide (Steam sign-in, a Steam API key), and
  each is asked for once, inline, with plain guidance — never "go to Settings first".
- Work that can run by itself does: dedupe, metadata, Steam sync, installed-game detection, recipes.
- When a design choice trades default convenience against configurability, **convenience wins** — say so in the
  branch's ADR.

## Shelf and router, never the engine (owner directive, ADR 0019)
Like the Cocoon launcher on J.R's AYN Thor: one front end, and each kind of game is run by the specialist app that
owns it. Retriever routes; it never emulates, translates or runs games itself.
- Native `.app` (including nxnative-built Switch ports) → direct launch. Mac Steam → `steam://`. Windows Steam →
  a CrossOver bottle. Emulated ROMs → the system's emulator app. Every route lives in the launch planning model.
- Nothing that runs games is bundled: no emulators, no cores, no engines. Retriever detects them, routes to them,
  and says honestly when one is missing (with its official page).

## User-provided files (owner directive, ADR 0019)
Anything that must come from the user's own sources — `prod.keys` for Switch builds, a console BIOS, a game's
`.nsp`/`.xci` — is asked for with **one** in-flow prompt: "Please provide your ___", a plain sentence on why, and a
file picker (`ProvideFilePrompt` / `UserFileRequest`). When the app knows where the file belongs (a BIOS folder), it
copies the user's file there, never overwriting.
- The app never sources, downloads, links to or hints at sources for these files. It asks; the user provides.

## UI / UX — Figma-ready, token-driven (owner directive, ADR 0004)
Figma designs will arrive later. Until then, **structure and function beat bespoke polish**.
- Every visual value (spacing, sizes, radii, colours, fonts, opacity, durations, grid metrics) comes from
  `Shared/DesignSystem/DesignTokens` and `Theme`. **Zero hardcoded visual values in views.**
  A SwiftLint custom rule rejects numeric literals in `.padding/.frame/.cornerRadius/.spacing` outside DesignSystem.
- Keep views **compositional**: screens are assembled from small reusable components so they can be re-skinned
  from Figma by editing tokens/components only — never by touching ViewModels, services, or models.
- No business logic or formatting logic in views.

## Testing & verification
- Unit tests for all non-UI logic (models, services, engines, ViewModels).
- Run `./scripts/build.sh` (XcodeGen + xcodebuild build + test) after every feature; fix every compile error
  before moving on.

## Data integrity rules (product invariants)
- **Playtime sources are never silently merged.** Every figure carries a `PlaytimeSource`
  (`steamSynced`, `macTracked`, `selfReported`, `hltbEstimate`). Totals are shown per source.
- Badges are computed **only from real recorded data** — never estimates, never fabricated.
- HowLongToBeat figures are always labelled **"HLTB estimate"**.
- Series part numbers are **never renumbered**; Up Next drops completed items but keeps original numbering.

## Secrets & legal
- The Steam Web API key lives **only in the Keychain**. Never in code, config, UserDefaults, logs, or git.
  The app must work gracefully with no key configured.
- The nxnative build engine is an **external, user-supplied tool** and is **never bundled**. Neither are
  console keys, firmware, or game files. `.gitignore` blocks common key/game file extensions.
- Troubleshooting actions must be **previewable, reversible, backup-first, and audit-logged**.
- File cleanup moves items to the **Trash** (`FileManager.trashItem`) and **never empties the Trash**.
- Guides: **link out only** to GameFAQs with full attribution. **No scraping, no embedding** of guide content.

## Git workflow
- **Never commit or push to `main`/`master`.**
- One branch per feature: `feature/<kebab-name>`; small clean commits; push to `origin`.
- **Conventional Commits** for every message: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
  (optional scope, e.g. `feat(steam): add owned-games client`).
- Unfinished work is still pushed, with a `WIP:` note in the commit body.
- Update `docs/PROGRESS.md` on every branch (built / compiles / stubbed / blocked).
