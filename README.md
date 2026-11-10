# nativehaul

A native macOS shelf for your Switch ports and emulated games: it adopts what is already on your Mac (existing
nxnative builds and ROM folders) with zero rebuilding, launches each game through the app that owns it, and has one
big tool inside, native Switch building on a **user-supplied, standalone nxnative** (never bundled). No sign-in
anywhere; the only accounts are API keys you paste (RetroAchievements, SteamGridDB, IGDB), kept in your Keychain.

## Features
- **Library** — SwiftData cover grid; sidebar sections Playing / Backlog / Completed; game detail; JSON import/export.
- **Playtime tracking** — NSWorkspace watcher logs sessions for tracked `.app` bundles (e.g. `~/Switch/Games`).
  Every figure carries its source (MacTracked, SelfReported, HLTB estimate); sources are never merged.
- **Series & collections** — recommended play order (release or chronological) and an Up Next strip that never renumbers.
- **Stats & badges** — backlog counts, hours by source, completion %, badges computed only from real data.
- **NXNative (on by default)** — build queue UI for a user-supplied external engine, found automatically: preflight checks, streamed logs,
  previewed cleanup (Trash only, never emptied), and a backup-first, audit-logged troubleshooting knowledge base.
- **Adoption** — first run and every rescan adopt existing nxnative builds (by folder, port library or the title ID
  stamped in the bundle) and ROM files, with zero rebuilding; strict dedupe and idempotent re-scans.
- **Emulator hub** — detects the emulators you installed (RetroArch and others), maps ROMs to systems, and launches
  each through its emulator. Emulators, cores, BIOS and ROMs are always yours; nothing is bundled.
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
open nativehaul.xcodeproj
```

### Build and test

```bash
./scripts/build.sh
```

It builds into Xcode's default DerivedData, the one canonical output on this Mac:
`~/Library/Developer/Xcode/DerivedData/nativehaul-<hash>/Build/Products/Debug/nativehaul.app` (the script prints the
full path). In Xcode: ⌘B / ⌘U build into the same folder.

### Lint and format

```bash
./scripts/lint.sh
```

Use `./scripts/lint.sh --check` to verify without rewriting files.

### Optional configuration
- **API keys** (all optional): Settings → Artwork for SteamGridDB and IGDB (Twitch client ID + secret), and
  Settings → RetroAchievements (username + web API key). Stored only in the macOS Keychain; without them the app
  works fully, using keyless titledb data for Switch media.
- **Game folders**: Settings → Game Folders. `~/Switch/Games` is scanned even if you configure nothing.
- **nxnative engine**: a standalone copy of upstream nxnative, found automatically in `~/Switch` or Homebrew
  (ADR 0021); `prod.keys` likewise. Settings → NXNative only overrides or switches the module off.
  nativehaul never ships the engine, keys, firmware, or game files.

## Architecture overview
- **SwiftUI + MVVM**: views render `@MainActor @Observable` ViewModels; no business logic in views.
- **Protocol-first services**: every service is a protocol with a live and a mock implementation; mocks
  power SwiftUI previews and unit tests.
- **SwiftData** persistence; JSON import/export for portability.
- **Design tokens**: all visual values live in `Shared/DesignSystem` so screens can be re-skinned from Figma.
- **Data integrity**: playtime is stored per source (Mac-tracked, self-reported, HLTB estimate) and
  never merged; badges only use real data.

See `docs/PLAN.md` for the roadmap and `docs/decisions/` for architecture decision records.

## Where things live

```
nativehaul/ (repo root)
├── project.yml                 XcodeGen spec (source of truth for the Xcode project)
├── CLAUDE.md                   Project rules for humans and AI contributors
├── scripts/                    bootstrap.sh · build.sh · lint.sh
├── docs/
│   ├── PLAN.md                 Architecture & roadmap
│   ├── PROGRESS.md             Build status log per branch
│   └── decisions/              ADRs (0001-…)
├── nativehaul/                    App source
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
└── nativehaulTests/               Unit tests mirroring the source tree
```

## Contributing
- Branch per feature: `feature/<kebab-name>`; never commit to `main`.
- Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).
- Run `./scripts/lint.sh` and `./scripts/build.sh` before pushing; update `docs/PROGRESS.md`.

## Releases, privacy and licence
- Releases: `scripts/release.sh` builds the signed, notarized and stapled DMG and the Sparkle appcast; see
  [docs/RELEASING.md](docs/RELEASING.md). Changes are listed in [CHANGELOG.md](CHANGELOG.md) (semantic versioning).
- Privacy: no telemetry and no account; every host the app talks to is in [docs/PRIVACY.md](docs/PRIVACY.md).

## License
MIT © 2026 Studio Jrba inc.: see [LICENSE](LICENSE). Third-party software and services are credited in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md); the audit is [docs/LICENSE_AUDIT.md](docs/LICENSE_AUDIT.md).
