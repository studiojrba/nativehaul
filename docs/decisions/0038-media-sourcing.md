# ADR 0038 — Media pass: slideshows never crop; trailers, screenshots and descriptions from official sources

**Status:** Accepted · 2026-11-09 (J.R's plan, confirmed Mon 18:48 EST)

## Context
J.R wants every game to show real media: a trailer when one exists, a slideshow of official screenshots, and the
official description. He reported a Kingdom Hearts II screenshot in the Builds slideshow cropped on all four sides
(the Commands menu clipped on the left, HUD text cut at the top, the minimap off the right).

The research behind the plan:
- Playnite gets trailers through its Extra Metadata Loader extension: Steam's trailer files first, then YouTube
  downloads through yt-dlp. **The yt-dlp leg is not copied.** It breaks YouTube's terms and breaks often.
- Playnite's descriptions come from IGDB.
- For Nintendo, blawar/titledb (on GitHub, regenerated from eShop data, keyed by NSUID) carries the official
  description and a `screenshots` array of direct Nintendo CDN images for each game.

## Decision

### 1. Slideshows never crop
- The media frame takes the shape of the slide it is showing: `MediaFit` sizes it as wide as the column allows,
  unless that would make it taller than a cap, in which case it narrows. Images use `scaledToFit`, so the frame
  and the image always have the same shape: nothing is cropped and nothing is letterboxed.
- `FittedMediaFrame` (Shared/DesignSystem) does the measuring and resizing. When the next slide has a different
  shape, the frame follows it in 0.35 s (instant under Reduce Motion).
- It is used in both slideshows: the Builds job showcase (cap 480 pt) and the game detail media (cap: the dial's
  hero height, 380 / 460 / 560 pt).
- **Visible consequence:** wide SteamGridDB heroes (about 3:1) now show at their own shape on the detail page, so
  they are shorter than the old fixed-height, cropped hero.

### 2. Nintendo media from titledb
- **Source:** titledb's `US.en.json` region file from `raw.githubusercontent.com/blawar/titledb`. It is the only
  file fetched, and US English is the region, since the library's titles are the US English names. It is about
  90 MB. `TitleDBStore` downloads it once and keeps a compact index (title ID, NSUID, name, description,
  screenshots, banner, about 58 MB) in `~/Library/Application Support/Playrite/TitleDB/US.en.index.json`. It
  refreshes after 30 days at most. If a refresh fails, the older cache stays in use. With no cache and no network,
  the dataset is absent for the session: the provider answers `unavailable`, and the port simply gets no titledb
  media, never an error.
- **Where a port's title ID comes from:** `Game.switchTitleID` when it was built through Retriever, otherwise the
  built app's bundle identifier, which nxnative stamps as `org.nxnative.<title id>` (`NXNativeAppTitleID`).
- **Joining title ID to NSUID:** region records are keyed by NSUID, but each one also carries its own title ID
  (`id`). Resolution in `TitleDBIndex`, in order:
  1. The record with the port's title ID.
  2. The base application of an update or add-on ID (`SwitchTitleID.baseID`, the same link `cnmts.json` records
     as `otherApplicationId`).
  3. A single exact normalised-title match.

  When several records share a title ID (a game and its "Nintendo Switch 2 Edition" listing), the one whose name
  matches the library title wins, then the one with the most screenshots, then the lowest NSUID (the original
  listing). Demos are dropped.
- **Why `versions.json` and `cnmts.json` are not downloaded:** the region records already carry title IDs, and
  the base-ID rule gives what `cnmts` would. Both files were checked against the library's three unmatched ports:
  none of those IDs appear in either file, so downloading them (1.8 MB + 50 MB) would add nothing.
- **What a match supplies:**
  - **Screenshots** feed the slideshow (`carousel`).
  - **The official description** fills `summary` only when it is empty.
  - **The key art** (`bannerUrl`, 1920×1080) fills an empty hero. It replaces an existing hero only under
    `HeroUpgradeRule`: the current hero must be SteamGridDB community art **and** narrower than 1920 px. Heroes set
    by hand, imported, or from another official source are never replaced.
  - **Covers** are not taken: titledb's portrait art is box art with rating badges.
- **Provenance and reporting:** fields record the new source `titleDB` ("Nintendo eShop (titledb)"). Every filled
  field writes a `metadata.fill` audit entry, and every hero swap writes a `metadata.heroUpgrade` entry, to the
  existing audit log.
- **Order:** titledb takes the Nintendo slot in the fetcher. It is asked only for Switch ports that have no Steam
  match, before SteamGridDB. The never-connected `NintendoStoreSearching` seam stays in the code but is no longer
  wired.
- **Measured against the real data** (titledb as of 2026-10-16): the index code decodes the region file in about
  0.35 s and keeps 36,162 listings. 15 of the 18 ports with a built app match by title ID. All 6 library ports
  without a built app match by exact title. That makes 21 of 24 library ports. The misses are *Fire Emblem:
  Fortune's Weave*, *Pokémon Pokopia* and *The Legend of Zelda: Ocarina of Time*, whose IDs (`0400…`) are not in
  titledb at all.
