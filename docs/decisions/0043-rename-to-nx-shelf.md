# ADR 0043 — Retriever becomes NX Shelf; data identifiers stay frozen

**Status:** Accepted · 2026-11-09 (J.R, Mon 21:29 EST)

## Context
J.R renamed the app to **NX Shelf**, with a narrower 1.0: Switch and emulators. His instruction: protect the data.
No library, setting or stored key may be lost. If a data identifier truly had to change, stop and flag it rather
than migrate silently.

## Decision
- **Public name: NX Shelf**, everywhere public:
  - the app's display name, bundle name and executable (`PRODUCT_NAME: NX Shelf`), so the build is now
    `NX Shelf.app`;
  - every user-facing string;
  - README, CLAUDE.md, PLAN and the PROGRESS title;
  - the update checker's repository;
  - the GitHub repository: `studiojrba/retriever` becomes `studiojrba/nx-shelf` (GitHub redirects the old URL).
- **Unchanged, as legacy internal identifiers** (`AppInfo`, guarded by `AppInfoTests`):
  - bundle ID `com.studiojrba.Playrite`, which is also the UserDefaults domain, so every setting carries over;
  - the `~/Library/Application Support/Playrite` folder (artwork, titledb cache, HLTB cache, audit log, backups);
  - the SwiftData store `default.store`, SwiftData's default location, independent of the app's name;
  - the Keychain service `com.studiojrba.Playrite` (Steam, SteamGridDB and IGDB keys);
  - the Swift module, project, scheme and source folders (`Playrite`).
- **Also kept, because they name things already on disk:** the CrossOver bottle names (`Retriever – <game>`,
  `Retriever Steam`), the installer folder inside those bottles, and the `.retriever-backup` suffix. They are
  marked in code as legacy identifiers.
- **Old app names:** the tracker's own-app exclusion list keeps the old bundle names (`Playrite.app`,
  `Retriever.app`) next to `NX Shelf.app`.
- **Nothing had to change:** no data identifier needed changing, so nothing was migrated and nothing was flagged.

## Consequences
- **Same app to macOS:** the bundle ID is unchanged, so macOS treats NX Shelf as the same app. Settings and
  privacy grants keyed to the bundle ID carry over.
- **Old build output:** the canonical build output is now `…/Debug/NX Shelf.app`. The stale `Retriever.app` left
  in the same folder is moved to the Trash, so only one copy can be launched (ADR 0029).
- **Historical records keep their names:** ADRs before this one, and earlier PROGRESS entries, keep the names they
  were written under.
- **Local checkout folder:** the checkout stays at `~/Projects/Retriever`. Moving it would change Xcode's
  DerivedData folder, and with it the canonical build path. Only the remote URL changes.
