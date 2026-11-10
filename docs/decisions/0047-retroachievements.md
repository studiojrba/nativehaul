# ADR 0047 — RetroAchievements by pasted key

**Status:** Accepted · 2026-11-09 (J.R, Mon 22:48 EST: the one new 1.0 feature)

## Context
1.0 has no sign-in anywhere (ADR 0046). J.R allowed one account-shaped feature beyond metadata keys:
RetroAchievements, using a username and web API key the user pastes, to show app-side achievements for emulated
games that RetroAchievements supports.

## Decision
- **Credentials:**
  - Settings has a RetroAchievements tab (username + web API key).
  - Both are stored in the Keychain (`com.studiojrba.NXShelf`, `retroachievements.username` and
    `retroachievements.apikey`), never read back into the UI, and read off the main thread (ADR 0044).
  - No OAuth and no login window.
- **The API** (`https://retroachievements.org/API/`, checked against the official API docs on 2026-11-09):
  - `API_GetGameList.php?i=<console>&h=1&f=1` gets each console's games and supported hashes. It is fetched once
    per session and cached, because the docs warn the response is large.
  - `API_GetGameInfoAndUserProgress.php?g=<game>&u=<username>` gets the user's progress.
  - The key travels as the documented `y` parameter, to `retroachievements.org` only, and is never logged.
  - Requests are spaced 0.5 s apart.
- **Identifying a ROM** (`RomHashRule`, from RetroAchievements' game-identification rules), MD5 of:
  - Game Boy, Game Boy Color, Game Boy Advance: the whole file;
  - NES: without the 16-byte iNES header when present;
  - SNES: without the 512-byte copier header when the size is 512 bytes past a multiple of 8 KB;
  - Nintendo 64: the big-endian (`.z64`) form of `.v64` and `.n64` dumps.

  Hashing runs off the main thread, with a 128 MB cap. A match is remembered on the game
  (`Game.retroAchievementsGameID`), so the ROM is hashed once.
- **Not identified yet:** disc-based systems and DS use RetroAchievements' more involved hashing. They show no
  section, and nothing pretends to identify them. Zipped ROMs aren't hashed.
- **Display** (`RetroAchievementsSection`, emulated games only):
  - "x of y · points", then the set in RetroAchievements' display order;
  - earned achievements at full strength with their badge, unearned ones dimmed with the locked badge
    (`media.retroachievements.org/Badge/<name>[_lock].png`).
  - If the hash isn't in the list, a plain line says so. If the service is down, a plain line says to try later.
  - Without credentials, or for a system NX Shelf can't identify, the section is absent: no nagging.

## Consequences
- **Not verified live:** there are no credentials yet, so the calls are covered by recorded-shape fixtures. The
  console IDs (GB 4, GBC 6, GBA 5, NES 7, SNES 3, N64 2) are RetroAchievements' standard IDs. The docs pages read
  did not list them; `API_GetConsoleIDs.php` can confirm them on the first live run.
- **No disc systems yet:** extending identification to them means implementing RetroAchievements' per-system disc
  hashing. That is a contained follow-up.
