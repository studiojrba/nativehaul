# Playrite

A native macOS game library hub — a Playnite-style library (Steam, Mac-native and Switch titles,
series, stats, badges, guides) plus an **optional** NX2Apple-style Switch build pipeline UI that drives a
**user-supplied external engine** (never bundled).

## Features
- **Library** — SwiftData cover grid; sidebar sections Playing / Backlog / Completed; game detail; JSON import/export.
- **Steam** — owned games, recently played and achievements via the Steam Web API; key stored only in the Keychain.
- **Playtime tracking** — NSWorkspace watcher logs sessions for tracked `.app` bundles (e.g. `~/Switch/Games`).
  Every figure carries its source (SteamSynced, MacTracked, SelfReported, HLTB estimate); sources are never merged.
- **Series & collections** — recommended play order (release or chronological) and an Up Next strip that never renumbers.
- **Stats & badges** — backlog counts, hours by source, completion %, badges computed only from real data.
- **NXNative (optional)** — build queue UI for a user-supplied external engine: preflight checks, streamed logs,
  previewed cleanup (Trash only, never emptied), and a backup-first, audit-logged troubleshooting knowledge base.
- **Guides & HLTB** — GameFAQs link-out guides with attribution and chapters; cached, labelled HowLongToBeat estimates.

## Quickstart

### Prerequisites
- Apple Silicon Mac, macOS 15 or later
- Xcode 16+ (developed with Xcode 27.2, Swift 6)
- Homebrew tools:

```bash
brew install xcodegen swiftformat swiftlint
```

### Generate the Xcode project
The project file is generated from `project.yml` and is not committed.

```bash
./scripts/bootstrap.sh
```

```bash
open Playrite.xcodeproj
```

### Build and test

```bash
./scripts/build.sh
```

(Equivalent to `xcodebuild -project Playrite.xcodeproj -scheme Playrite build test`.) In Xcode: ⌘B / ⌘U.

### Lint and format

```bash
./scripts/lint.sh
```

Use `./scripts/lint.sh --check` to verify without rewriting files.

### Optional configuration
- **Steam**: Settings → Steam. Paste your Steam Web API key and SteamID64. The key is stored only in the
  macOS Keychain. Without a key the app works fully offline.
- **nxnative engine** (optional): Settings → NXNative. Point Playrite at your own copy of the engine.
  Playrite never ships the engine, keys, firmware, or game files.

## Architecture overview
- **SwiftUI + MVVM**: views render `@MainActor @Observable` ViewModels; no business logic in views.
- **Protocol-first services**: every service is a protocol with a live and a mock implementation; mocks
  power SwiftUI previews and unit tests.
- **SwiftData** persistence; JSON import/export for portability.
- **Design tokens**: all visual values live in `Shared/DesignSystem` so screens can be re-skinned from Figma.
- **Data integrity**: playtime is stored per source (Steam, Mac-tracked, self-reported, HLTB estimate) and
  never merged; badges only use real data.

See `docs/PLAN.md` for the roadmap and `docs/decisions/` for architecture decision records.

## Where things live

```
Playrite/
├── project.yml                 XcodeGen spec (source of truth for the Xcode project)
├── CLAUDE.md                   Project rules for humans and AI contributors
├── scripts/                    bootstrap.sh · build.sh · lint.sh
├── docs/
│   ├── PLAN.md                 Architecture & roadmap
│   ├── PROGRESS.md             Build status log per branch
│   └── decisions/              ADRs (0001-…)
├── Playrite/                   App source
│   ├── App/                    Entry point, RootView, AppEnvironment
│   ├── Features/
│   │   └── <FeatureName>/
│   │       ├── Views/          SwiftUI views (each with a #Preview)
│   │       ├── ViewModels/     @Observable view models
│   │       ├── Models/         SwiftData models & value types
│   │       ├── Services/       Protocols, live + mock implementations
│   │       └── Resources/      Feature-specific resources (e.g. seed JSON)
│   └── Shared/
│       ├── DesignSystem/       DesignTokens, Theme, reusable components
│       ├── Networking/         HTTP client protocol + implementations
│       ├── Persistence/        SwiftData container & schema
│       └── Utilities/          Formatters, Keychain, helpers
└── PlayriteTests/              Unit tests mirroring the source tree
```

## Contributing
- Branch per feature: `feature/<kebab-name>`; never commit to `main`.
- Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).
- Run `./scripts/lint.sh` and `./scripts/build.sh` before pushing; update `docs/PROGRESS.md`.
