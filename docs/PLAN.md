# Playrite — Architecture & Roadmap

## Vision
A native macOS hub for your whole game library: Steam, Mac-native titles, and Switch titles you have
legally dumped and converted with an external engine. Think Playnite's library and metadata, plus an
optional, unbundled build pipeline UI in the spirit of NX2Apple.

## High-level architecture

Single app module, strict feature folders (see `README.md` for the full tree).

```
Playrite/
├── App/            PlayriteApp, RootView, AppEnvironment (dependency container)
├── Features/
│   ├── Library/        SwiftData models (Game, PlaySession…), grid, sidebar, detail, JSON import/export
│   ├── Steam/          SteamClientProtocol + URLSession client, DTOs, sync, settings
│   ├── Tracking/       PlaytimeWatching (NSWorkspace notifications), session logger
│   ├── Series/         Series, Collection, SubGame, UpNextEngine (true order, never renumber)
│   ├── Stats/          StatsCalculator, BadgeEngine (real data only), stats page
│   ├── NXNative/       Optional external engine: preflight, queue, logs, cleanup, troubleshooting KB
│   └── Guides/         GameFAQs link-out (attribution, no scraping), HLTB cache (labelled estimates)
└── Shared/
    ├── DesignSystem/   DesignTokens, Theme, reusable components (Figma-ready)
    ├── Networking/     HTTPClient protocol + URLSession implementation
    ├── Persistence/    ModelContainer factory, schema
    └── Utilities/      Formatters, Keychain SecretStore, clocks, file helpers
```

Each feature: `Views/` → `ViewModels/` (`@MainActor @Observable`) → `Services/` (protocol + live + mock)
→ `Models/`. Views never touch services directly.

### Key decisions (see `docs/decisions/`)
- ADR 0001 — SwiftData for persistence.
- ADR 0002 — Protocol-first services with mock implementations for previews and tests.
- ADR 0003 — XcodeGen (`project.yml`) for a reproducible project; `.xcodeproj` is git-ignored.
- ADR 0004 — Central design-token system; views are token-driven and Figma-ready.
- ADR 0005 — Single app module with feature folders (no separate framework).
- ADR 0006 — Playtime stored per source, never merged.
- **Not sandboxed**: the app must observe `~/Switch/Games`, launch a user-supplied external CLI, and
  move files to the Trash. Distribution target is Developer ID + hardened runtime.

## UI / UX approach (owner directive)
Figma designs will be supplied later. Views are strictly **token-driven** (`DesignTokens` + `Theme`;
zero hardcoded visual values) and **compositional** (screens built from small components), so they can
be re-skinned from Figma without touching ViewModels, services, or models. Structure and function take
priority over bespoke visual polish for now.

## Roadmap — V1 (one branch each, built in order)
| # | Branch | Scope |
|---|--------|-------|
| 0 | `feature/project-foundation` | Rules, plan, README, ADRs, XcodeGen project, lint/format configs, design tokens, scripts |
| 1 | `feature/library-core` | SwiftData models, cover-grid library, sidebar (Playing/Backlog/Completed), detail view, JSON import/export |
| 2 | `feature/steam-provider` | Steam Web API client (GetOwnedGames, GetPlayerAchievements, GetRecentlyPlayedGames), Keychain-only key, graceful no-key mode |
| 3 | `feature/playtime-tracking` | NSWorkspace watcher for tracked `.app` bundles, sessions with source labels, never merged |
| 4 | `feature/series-collections` | Series w/ recommended order + basis, Collections of ordered SubGames, Up Next strip |
| 5 | `feature/stats-badges` | Stats page (backlog counts, hours by source, completion %), badge engine from real data |
| 6 | `feature/nxnative-module` | Optional unbundled engine interface: queue, preflight, streamed logs, cleanup, troubleshooting KB |
| 7 | `feature/guides-hltb` | GameFAQs link-out with attribution (no scraping), cached HLTB layer labelled "HLTB estimate" |

## Next step after V1
- **GitHub Actions CI** (`feature/ci`): macOS runner on every pull request — install XcodeGen/SwiftLint/SwiftFormat,
  `./scripts/lint.sh --check`, `xcodegen generate`, `xcodebuild build test`. *(Planned only — not built in V1.)*

## Later ideas
- Cover art fetching (SteamGridDB, user-supplied key in Keychain), additional providers (GOG, Epic, itch.io).
- Figma re-skin pass once designs arrive (tokens + components only).

### Branching note
The GitHub repo was empty (no commits on `main`). Because work must never be committed to `main`,
feature branches are **stacked**: each is created from the previous feature branch's tip. Merge them
into `main` in order (0 → 7); each PR's diff against its predecessor is the feature's change set.
