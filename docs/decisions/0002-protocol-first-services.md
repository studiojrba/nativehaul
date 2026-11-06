# ADR 0002 — Protocol-first services with mocks

**Status:** Accepted · 2026-11-06

## Context
Services talk to the network (Steam, HLTB), the Keychain, NSWorkspace and an external CLI engine. These are
slow, stateful or unavailable in previews and CI.

## Decision
Every service is declared as a **protocol** describing the capability. Each has a **live** implementation and a
**mock** implementation living next to it in `Features/<X>/Services/` (or `Shared/…`). ViewModels depend on the
protocol; `AppEnvironment` wires live implementations, previews and tests wire mocks.

## Consequences
- Views/ViewModels are previewable and testable offline and deterministically.
- Slightly more files per service (protocol + live + mock) — accepted; aligns with one-type-per-file.
- Protocols must be `Sendable` where they cross actor boundaries.
