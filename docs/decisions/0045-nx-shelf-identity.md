# ADR 0045 — NX Shelf owns a brand-new identity (supersedes the frozen identifiers of ADR 0029 and ADR 0043)

**Status:** Accepted · 2026-11-09 (J.R, Mon 22:48 EST: "no legacy, brand new, as if it was NX Shelf all along")

## Context
ADR 0043 renamed the app but kept the Playrite-era data identifiers frozen, so the library and settings would carry
over. J.R reversed that. NX Shelf starts fresh. What carries over is the code and the feature progress, not the
stored data. The new app re-adopts his games by scanning the disk, which is the 1.0 design anyway.

## Decision
- **New identity:**

  | | Value |
  |---|---|
  | Bundle ID (and UserDefaults domain) | `com.studiojrba.NXShelf` (tests: `com.studiojrba.NXShelfTests`) |
  | Application Support folder | `~/Library/Application Support/NX Shelf` |
  | SwiftData store | `NX Shelf/NXShelf.store` (explicit URL; no longer SwiftData's shared default `default.store`) |
  | Keychain service | `com.studiojrba.NXShelf` |
  | Project, scheme, targets, source folders, Swift module | `NXShelf`, `NXShelfTests` |
  | App bundle | `NX Shelf.app` |

- **One source for the identity:** every location the app writes goes through `AppInfo.supportDirectory`:
  - the artwork cache;
  - the titledb cache;
  - the HLTB cache;
  - the audit log;
  - script backups;
  - the store.
- **Nothing reads, points at or migrates the old identity's data.** `AppInfoTests` fails if any source mentions
  the old bundle ID, the old support folder, `default.store`, or the Retriever name.
- **Removed as legacy:**
  - the one-time tracker repair (`TrackedSessionRepair`), which only existed to fix data under the old identity;
  - the old app names in the tracker's own-app exclusion list.
- **Canonical build path:** the build now lands in Xcode's DerivedData folder for the `NXShelf` project
  (`DerivedData/NXShelf-<hash>/…/Debug/NX Shelf.app`).

## Consequences
- **An empty first launch:** NX Shelf opens with an empty library and adopts games by scanning (1.0 scope surgery,
  ADR 0046). Settings and keys entered under the old identity don't appear; keys are re-pasted once.
- **The old data is orphaned, not deleted:** J.R decides the purge separately. The list is in PROGRESS.
