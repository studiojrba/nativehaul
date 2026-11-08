# ADR 0029 — The app is called Retriever; data identifiers stay frozen; one canonical build output

- Status: accepted (J.R, 2026-11-07 18:54 EST)
- Branch: `feature/app-rename-retriever`, stacked on `feature/builds-detail-showcase`

## Context
The product is now called **Retriever** (the GitHub repo was already renamed to `studiojrba/retriever`). The code still
said Playrite everywhere: bundle filename, Dock and menu bar name, window titles and user-facing copy.

J.R's library on this Mac is real, so the rename must not move or orphan any data. Each piece of data is keyed on one
of the following:

| Data | Keyed on | Depends on the app name? |
|---|---|---|
| SwiftData library | `~/Library/Application Support/default.store` (SwiftData's default; the app is not sandboxed) | No |
| Settings (UserDefaults) | bundle ID `com.studiojrba.Playrite` | No |
| Steam and SteamGridDB keys | Keychain service `com.studiojrba.Playrite` (hardcoded) | No |
| Artwork, HLTB cache, audit log, backups | `~/Library/Application Support/Playrite/…` (hardcoded) | No |
| Swift module (`@testable import`) | `PRODUCT_MODULE_NAME`, which defaults to `PRODUCT_NAME` | Yes, so it is pinned |

Separately, J.R kept finding **two copies of the app open**: one launched from Xcode's default DerivedData and one from
the `build/DerivedData` folder that `build.sh` used.

The rename brief cited (`~/workspace/playrite/rename-brief.md`) was not on this Mac. The requirements in J.R's GO
message were used instead.

## Decision
1. **User-facing name is Retriever:**
   - `PRODUCT_NAME: Retriever` produces `Retriever.app` with a `Retriever` executable, so `CFBundleName` (menu bar
     and About) is Retriever.
   - `INFOPLIST_KEY_CFBundleDisplayName: Retriever` covers the Dock and Finder.
   - Window titles come from the bundle name.
   - Every user-facing string and doc comment that said Playrite now says Retriever. That includes the launch failure
     title, tracking toggles, the HLTB and guide notes, the NXNative disclaimer and preflight text, and the library
     export filename.
2. **Filename `Retriever.app`: low risk, so done.** None of the data above depends on the bundle filename. The one
   build-level dependency, the module name, is pinned with `PRODUCT_MODULE_NAME: Playrite`. `TEST_HOST` points at
   `Retriever.app/Contents/MacOS/Retriever`. The library scanner still excludes `Playrite.app` as well as
   `Retriever.app`, in case an old copy is lying in a scanned folder.
3. **Frozen identifiers are named in one place:**
   - `AppInfo` holds `bundleIdentifier`, `supportFolderName`, `keychainService` and `storeFileName`, and
     `KeychainSecretStore` takes its default service from it.
   - Tests pin every value. They also check the real Application Support paths, the SwiftData default store URL,
     and that the test host bundle is `Retriever.app` with the frozen bundle ID.
4. **Unchanged internals:** the project, scheme, target, source folders, type names (`PlayriteApp`,
   `PlayriteSchema`) and the notification and queue labels stay as they are. Renaming them buys nothing for users and
   risks churn.
5. **One canonical build output:**
   - `build.sh` no longer passes `-derivedDataPath`. It builds into Xcode's default DerivedData for the project, the
     same folder Xcode uses, and prints the app path at the end:
     `~/Library/Developer/Xcode/DerivedData/Playrite-exinnpzvysdovkcwpocorbnjqrch/Build/Products/Debug/Retriever.app`
   - The old `build/DerivedData` folder and the stale `Playrite.app` products are moved to the Trash (never deleted).
   - Any instance launched for verification is quit before the session ends.

## Consequences
- J.R's library, settings, keys and artwork carry over with no migration. Verification launched the renamed build
  against the real library and confirmed it loads in full.
- macOS treats `Retriever.app` as a new path. Because of the ad-hoc signature, privacy prompts may reappear, which
  already happens after every Debug rebuild.
- Dock pins or Login Items that pointed at `Playrite.app` need re-adding with `Retriever.app`.
- Renaming the project, scheme or folders to Retriever later is possible, but it is a separate change with no user
  impact. The frozen identifiers must never change without a real data migration.
