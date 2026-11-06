# ADR 0008 — NXNative is an optional, unbundled, non-destructive module

**Status:** Accepted · 2026-11-06

## Context
Playrite can drive an external "nxnative" engine that converts a user's own Switch titles into native macOS apps.
The engine, console keys, firmware and game files must never be distributed with Playrite. Build cleanup and
troubleshooting touch the user's files, so mistakes must be recoverable.

## Decision
- The module is **off by default**; the user enables it and chooses their own engine path. Preflight fails if the
  engine path is inside Playrite.app. A unit test asserts the built app bundle contains no engine, key or title files.
- All file access goes through `FileOperating`, which has **no delete and no empty-Trash operation**. Cleanup can only
  move items or move them to the Trash. A policy test scans the source tree for deletion/Trash-emptying APIs.
- Cleanup is **planned, previewed and approved**: keep exactly one `.app` (renamed to the real title, never
  overwriting), keep the hidden library folder, Trash leftovers, and leave anything ambiguous untouched.
- Preflight checks: engine present, engine external, title ID format (non-retail = warning), 64-bit (32-bit and
  unknown are refused), staged-file inventory, free space (source × multiplier), output folder.
- Troubleshooting cases live in a bundled JSON knowledge base. Steps are previewable, run in order, backup-first
  (hash-verified), reversible, and audit-logged to an append-only JSON Lines file.

## Consequences
- Users must supply and configure the engine; Playrite cannot build anything out of the box (by design).
- The engine's CLI is unknown, so arguments are a configurable template (`{input} {output} {titleID} {title}`);
  title metadata (name, ID, architecture) is entered by the user rather than inspected.
