# ADR 0005 — Single app module with feature folders

**Status:** Accepted · 2026-11-06

## Context
The owner requires a strict, walk-in-understandable layout: `App/`, `Features/<Name>/{Views,ViewModels,Models,
Services,Resources}`, `Shared/{DesignSystem,Networking,Persistence,Utilities}`. An initial draft used a separate
`PlayriteCore` framework, which split each feature across two trees.

## Decision
Use a **single app target** organised by feature folders. Unit tests (`PlayriteTests`) use `@testable import
Playrite` with the app as test host. Access control is `private` by default.

## Consequences
- Every feature lives in one folder; easy navigation and ownership.
- No module boundary enforces "no UI in services" — enforced by convention, review, and folder rules instead.
- Can be split into SPM packages later if build times or reuse demand it.
