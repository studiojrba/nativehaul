# ADR 0034 — Tracked sessions: one per game, ended by the game, checked for liveness, capped

- Status: accepted for **new** sessions (QA Finding #7, J.R moved it to the top of the queue, 2026-11-09).
  - **Already-stored stale sessions are untouched.** What to do with them is J.R's call (options below).
- Branch: `fix/tracker-liveness`
- Related: ADR 0030 (handoff, Layer 1), Finding #6 (focus)

## Context — what Ollie found, confirmed from a read-only copy of the store
Ollie decomposed Ocarina's 88h 20m on the Jump Back In shelf. The copied store (`default.store`, queried in a scratch
folder, the live file never opened for writing) shows every MacTracked session:

| Game | Started | Ended | Length | What it was |
|---|---|---|---|---|
| Ocarina | Nov 7 06:52:01 | Nov 7 18:55:10 | 12h 03m | stale, closed when Retriever quit for the rename |
| Ocarina | Nov 7 18:51:06 | Nov 7 18:53:34 | 2m | genuine |
| Ocarina | Nov 7 18:58:32 | Nov 7 19:00:27 | 1m 55s | genuine |
| Ocarina | Nov 7 19:19:22 | Nov 9 09:26:32 | 38h 07m | **launcher** of the next row, closed when Retriever quit this morning |
| Ocarina | Nov 7 19:20:32 | Nov 7 22:14:38 | 2h 54m | genuine (the game host) |
| Smash | Nov 7 22:15:20 | Nov 9 09:26:32 | 35h 11m | **launcher** of the next row |
| Smash | Nov 7 22:15:22 | Nov 7 22:18:17 | 2m 55s | genuine (the game host) |
| Ocarina | Nov 7 22:18:32 | Nov 9 09:26:32 | 35h 08m | **launcher** of the next row |
| Ocarina | Nov 7 22:18:34 | Nov 7 22:22:22 | 3m 48s | genuine (the game host) |

**Cause:**
- A built port runs as **two processes from the same `.app`**: the launcher (its main executable) and the game host
  (`Contents/MacOS/dmhost`), which starts when the user presses Play in the launcher window.
- The old tracker opened **one session per process**, so every Play made two overlapping sessions.
- The game host's session closed correctly when the game quit; its log ends `launcher: the host exited with 0`.
- The launcher's session stayed open until its exit event arrived. That event never came, either because the launcher
  window stayed open or because the exit was missed. Nothing re-checked, so the session closed only when Retriever
  itself quit (`finishAll`) at 18:55 on Nov 7 and at 09:26 this morning.
- Two smaller exposures in the same code:
  - a Mac asleep with a game open was counted as play;
  - a game already running when Retriever started was dated from its launch, even if part of that run was already
    stored (the double-count risk flagged on Nov 7).
- The ADR 0030 handoff had the same weakness: a lingering launcher, or a missed exit, would keep Retriever hidden.

## Decision (new sessions only)
- **One run per game, not per process (dedupe).** All processes of a tracked game form one run. Overlapping launcher
  and game sessions can't happen any more.
- **The game ends it, not the launcher.** A process running an executable other than its bundle's main one is a
  *helper* (for a port, the game host). The live observer tells them apart from `NSRunningApplication.executableURL`.
  Once a helper has run:
  - only time while a helper runs counts;
  - the launcher's wait before Play is dropped, and a launcher window left open after the game quits isn't play;
  - pressing Play again in that launcher starts a new session.
  - A game with no helper (ordinary Mac apps) counts while any of its processes runs, as before.
- **Liveness sweep, every 60 s (`PlaytimeWatcher.sweepInterval`).** Each tracked process is checked with
  `NSRunningApplication(processIdentifier:)` and must still belong to the same bundle (process ID reuse). A process
  that's gone without an exit event ends at the **last sweep that saw it alive**, so the error is at most a minute.
- **Cap and flag at 12 hours (`SessionTracker.maximumSessionSeconds`).**
  - A stretch still counting after 12 h is stopped at exactly 12 h and stored with the note "Stopped at the 12-hour
    cap…", so it can be reviewed.
  - The run then stops counting until a new process of the game appears.
  - This catches the one case liveness can't: a game or launcher genuinely left open overnight.
- **Sleep ends the stretch.** `NSWorkspace.willSleep` closes it and `didWake` starts a new one if the game is still
  running.
- **No double count after a restart.** A new stretch never starts before the end of the game's last stored MacTracked
  session.
- **Handoff (ADR 0030 Layer 1) uses the same rules.** Retriever comes back when the port's game host exits, even if
  the launcher stays open. A 5 s liveness check (`GameSessionHandoff.livenessInterval`) means a missed exit can't
  leave Retriever hidden.
- Schema unchanged: the flag uses `PlaySession.note`, which already exists. No migration, and **no stored row is
  read for writing, changed or deleted**.

## Already-booked stale sessions — options for J.R (nothing done until he rules)
**Rule to identify them.** A MacTracked session is suspect if either:
- it contains another MacTracked session of the same game (the launcher half of a pair); or
- it is longer than 12 h.

That rule picks exactly the four stale rows above and none of the genuine ones:

| Game | Shown now | Suspect | Left after removing suspects |
|---|---|---|---|
| Ocarina | 88h 20m | 85h 18m (3 sessions) | **3h 02m** |
| Smash | 35h 14m | 35h 11m (1 session) | **2m 55s** |

**Options:**
- **A. Leave them.** The shelf keeps showing 88h 20m and 35h 14m. Only new sessions are correct.
- **B. Flag and leave out (recommended).**
  - Each suspect gets the review note and drops out of MacTracked totals. Nothing is deleted, and it's reversible.
  - The session list still shows each one, marked, with a way to put it back.
- **C. Remove them.**
  - Export a JSON backup first (backup-first rule). Then delete the four suspect `PlaySession` rows, and write the
    removal to the audit log.
  - The cleanest totals, but not reversible without the backup.
- **D. Trim them.** Set each launcher half's end to its game host's end. Not recommended: the trimmed launcher half
  would still overlap the genuine game session, so time would still be counted twice.

## Consequences
- New port sessions match the time the game ran. The Nov 7 pairs would have recorded 2h 54m, 2m 55s and 3m 48s, with
  nothing left open.
- Worst-case error for a missed exit is one sweep (60 s). Worst case for a game left open is a flagged 12 h session
  instead of an unbounded one.
- The launcher's few seconds to a minute before Play are no longer counted for ports.
- A non-port Mac game that sits idle in front still counts until the cap. Counting only frontmost time is possible
  later (the game already pauses itself when unfocused, Finding #6), but it's a separate decision.
- **Not verified live** (no Play clicks against J.R's library). The fix is covered by mock-driven tests, including a
  replay of the 19:19:22 / 19:20:32 Ocarina pair.
