# ADR 0033 — "Jump Back In" shelf on All Games

- Status: built (J.R's overnight licence, 2026-11-08; he keeps or reverts the branch)
- Branch: `feature/jump-back-in`

## Context
Ollie researched what launcher users value (Playnite, GOG Galaxy and Ark Pixels patterns) against J.R's library: 125
games, mostly Backlog, with tracked sessions and statuses. A "continue playing" row is the most-used pattern. Picking
up where you left off should take no searching.

## Decision
- **Who is on it:** games with status Playing, or with a recorded session that ended in the last 30 days.
- **Order:** most recent session first. When a game has no session, its last-played date counts. Games with neither
  come last, by title.
- **Where it shows:** a single horizontal row at the top of **All Games** only. It hides while searching, and it
  hides entirely when nobody qualifies (no header, no empty box).
- **Card:**
  - the normal cover card (ADR 0025);
  - a quiet subtitle saying when the game was last played ("Today", "Yesterday", "3 days ago", or a date after a
    week);
  - a second quiet line with the time played from the game's largest real source, labelled
    (`42h 00m · SteamSynced`). Sources are never added together (ADR 0006), and HLTB estimates never appear.
  - A game with nothing recorded shows its status.
  - The two parts sit on two lines, because one line was cut off at card width in the first render.
- **Data:** computed from data the library already has (`JumpBackIn`). No stored data, no settings, no store changes.

## Consequences
- Full value on defaults (zero-tinker, ADR 0016).
- **Completed games (J.R ruling, 2026-11-09):** the shelf is games whose status is Playing, or played within 30 days
  and not Completed. A Completed game leaves the shelf and comes back only when the user sets it to Playing; a fresh
  session alone never brings it back.
- Renders in `docs/design/jump-back-in/`.
