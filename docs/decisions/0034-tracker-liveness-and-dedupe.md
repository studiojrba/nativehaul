# ADR 0034 — Tracked sessions: one per game, ended by the game, checked for liveness, capped

- Status: accepted (QA Finding #7, J.R moved it to the top of the queue, 2026-11-09).
  - **Stored stale sessions: cleaned, by J.R's ruling (Mon 09:36 EST).** He told me to apply the fix's own rules
    retroactively (see "Retroactive cleanup — applied" below). Options A–D are kept for the record.
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
- The launcher's session stayed open until its exit event arrived. That event never reached the tracker. Nothing
  re-checked, so the session closed only when Retriever itself quit (`finishAll`) at 18:55 on Nov 7 and at 09:26 this
  morning.
- **The launchers did not linger: the exits were missed.** The macOS system log (WindowServer process lifecycle,
  read with `log show`) records when each app's process was created and when its serial number was removed (the
  process died). Every launcher died within 0.2 s of its game host:

  | Process | Created | Died |
  |---|---|---|
  | Ocarina launcher, pid 9543 | Nov 7 06:52:01 | 18:53:34.738 (its host, pid 10932, created 18:51:05, died 18:53:34.659) |
  | Ocarina launcher, pid 15956 | 19:19:22 | 22:14:38.573 (host pid 16231 died 22:14:38.487) |
  | Smash launcher, pid 18090 | 22:15:20 | 22:18:17.437 (host pid 18093 died 22:18:17.339) |
  | Ocarina launcher, pid 18154 | 22:18:32 | 22:22:22.516 (host pid 18155 died 22:22:22.313) |

  So the 06:52 row was also a launcher-and-host pair. The launcher window sat open from 06:52 until Play was pressed
  at 18:51, and the game ran for 2 m 28 s. Why `NSWorkspace` didn't deliver, or the tracker didn't match, the
  launcher's exit isn't known. The liveness sweep closes that gap whatever the cause.
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

## Already-booked stale sessions — options considered before J.R ruled
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

## Retroactive cleanup — applied (J.R ruling, 2026-11-09 09:36 EST)
J.R: "100% fix that tracker bug now", and clean the provably stale sessions by applying the fix's own liveness and cap
logic retroactively. Anything the rule can't prove stays untouched and is listed.

- **The rule (`StaleSessionPlan`, pure, tested):**
  - **Launcher half of a pair:** a MacTracked session that contains another MacTracked session of the same game is a
    port's launcher process. Under the fix only the game host's time counts, and the host's session is already
    stored, so the whole launcher row is excess and is removed.
    - The system log proves each of the four was a launcher that died with its host (table above).
    - Even closed at its real death time, each would only re-cover its host's time plus the wait before Play.
  - **Overlap:** a session running into the next one of the same game ends where the next starts.
  - **Cap:** a session still over 12 h ends at 12 h and is flagged.
  - On J.R's data, overlap and cap match nothing. The rule removes exactly the four launcher rows.
- **How it ran (`TrackedSessionRepair`):**
  - once, at launch, before tracking starts, guarded by `tracking.staleSessionRepair.v1.done` in UserDefaults;
  - each removed or trimmed session is written to the audit log (`Application Support/Playrite/Audit/audit.jsonl`)
    with its ID and original times;
  - a full copy of the store was made first (backup-first rule).
- **Also corrected:** a game's `lastPlayedAt` when it equals a removed session's end. Both games had
  `lastPlayedAt` = Nov 9 09:26:32, which is Retriever's quit time, not play. It now comes from the last real session.
- **Nothing else changes:** SteamSynced, SelfReported and HLTB figures, and every other game's sessions.

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
