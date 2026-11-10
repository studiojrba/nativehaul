# ADR 0048 — The name is locked: nativehaul

**Status:** Accepted · 2026-11-10 (J.R, Message 11: "NAME LOCKED")

## Context
ADR 0045 gave the app a brand-new identity under a working name. J.R then chose the final name, **nativehaul**, his
own coinage. He deep-checked that it is free: no GitHub user or repos, no App Store app, no company or trademark
hits, and the domains are open. The wordmark is lowercase and one word.

## Decision
- **The working name is swapped out everywhere for nativehaul**, on the same fresh-start terms as ADR 0045:

  | | Value |
  |---|---|
  | Display name, wordmark | `nativehaul` (always lowercase, one word) |
  | Bundle ID (and UserDefaults domain) | `com.studiojrba.nativehaul` (tests: `com.studiojrba.nativehaulTests`) |
  | Application Support folder | `~/Library/Application Support/nativehaul` |
  | SwiftData store | `nativehaul/nativehaul.store` |
  | Keychain service | `com.studiojrba.nativehaul` |
  | Project, scheme, targets, source folders, Swift module | `nativehaul`, `nativehaulTests` |
  | App bundle | `nativehaul.app` |
  | GitHub | `studiojrba/nativehaul` (renamed from `studiojrba/nx-shelf`; GitHub redirects the old URL) |

- **Swift type names** follow the API guidelines: `NativehaulApp`, `NativehaulSchema`.
- **Docs, strings and ADRs are swept,** so they read as if the app had always been nativehaul. Two exceptions:
  - real git branch names, which are facts;
  - this ADR and the PROGRESS state note, which must name what was swapped and what was left on disk.
- **No migration.** Nothing reads, points at or migrates the working-name data. `AppInfoTests` now also fails if
  any source mentions the working name's bundle ID, support folder, store name or display name.
- **Local project folder:** when it is renamed between sessions, it becomes `nativehaul` (not the working name).

## Consequences
- The working-name data on J.R's Mac is orphaned and listed in PROGRESS; J.R decides the purge.
- The canonical build moves to `DerivedData/nativehaul-<hash>/Build/Products/Debug/nativehaul.app`.
- The Keychain starts empty under the new service, so any keys J.R pastes are pasted once more.
