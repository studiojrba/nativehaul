# ADR 0001 — SwiftData for persistence

**Status:** Accepted · 2026-11-06

## Context
Playrite stores a local library (games, sessions, series, collections) with relationships, queried by
status and sorted in the UI. It targets macOS 15+ only.

## Decision
Use **SwiftData** (`@Model`, `ModelContainer`, `@Query`) as the persistence layer. Library portability is
provided separately by a versioned JSON import/export format (DTOs decoupled from `@Model` classes).

## Consequences
- Native SwiftUI integration (`@Query`), no third-party dependency, in-memory containers for previews/tests.
- `@Model` classes are not `Sendable`; all model access stays on the main actor (or a `ModelActor`).
- Schema changes need `VersionedSchema` migrations once data ships to users.
- JSON DTOs keep export stable even if the SwiftData schema evolves.
