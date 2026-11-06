# ADR 0004 — Central design-token system

**Status:** Accepted · 2026-11-06

## Context
The owner will supply Figma designs later. Screens built now must be re-skinnable without rewriting logic.

## Decision
All visual values live in `Shared/DesignSystem/DesignTokens.swift` (spacing, radii, sizes, typography,
opacity, motion, line limits) and `Theme.swift` (semantic colours). Views are composed from small reusable
components in `Shared/DesignSystem/Components`. A SwiftLint custom rule rejects numeric literals in
`.padding/.frame/.cornerRadius/.spacing` outside the design system.

## Consequences
- Re-skinning from Figma = editing tokens/components; ViewModels and services are untouched.
- Some verbosity (`DesignTokens.Spacing.md` instead of `12`) — accepted.
- Visual polish is intentionally deferred; structure and function come first.
