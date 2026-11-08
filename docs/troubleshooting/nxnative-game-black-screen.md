# A built game shows a black screen

*Seeded case `nxnative-game-black-screen` in
`Playrite/Features/NXNative/Resources/TroubleshootingKnowledgeBase.json`. Found in QA Finding #6 (2026-11-07, the
Ocarina port).*

## Symptom
You press Play on a game you built and its window stays black. Sometimes the music plays over the black screen,
sometimes there is no sound at all. The game keeps running and does not crash.

## Cause
A built game only draws while its window is in front and selected, the way a console game pauses when you leave it.
- If another window covers it, or another app takes the focus, the game pauses itself and the screen stays black.
- The music can keep playing while it waits. In windowed mode the intro music played over black; in full screen the
  game paused before the intro started, so there was no sound either.
- The first start can take about 30 seconds, while the game shows its own progress screen.

None of this means the build failed, and nothing needs rebuilding.

## What to check (guided in Retriever → Builds → Knowledge Base)
These are things to check on the game. They change nothing on your Mac, so there is no backup step and nothing to undo.

1. **Bring the game to the front.** Click once inside its window and close or move anything covering it.
2. **Keep it in front while it starts.** Don't switch apps. If you chose full screen in the game's own launcher, stay
   in its full-screen space.
3. **Give the first start about 30 seconds.** The game shows its own progress screen while it prepares its graphics.
4. **An intro movie can play black with sound.** Bring the window to the front and wait for the title screen.
   - The game's log is at `~/Library/Logs/nxnative/<title ID>.log`, and the run before that one is in `.prev.log`.
   - It may show `a packet refused with 12 pictures waiting for a released buffer` while the movie plays. That line
     alone is harmless.

## How the evidence looked (for maintainers)
- **Black state:**
  - CPU was about 8%, and nearly every thread was waiting.
  - The game's main thread was waiting for a focus message.
  - The port's log showed `oe focus state → 2` and `front end: window covered`.
- **Window in front:**
  - The title screen drew at 60 fps.
  - The prebuilt pipeline archive covered every pipeline it probed (0 compiled at launch), so this is not a shader
    compile.
- **Retriever's part:** Retriever's Play opens the game in front (`activates = true`) and never takes the focus back
  (ADR 0030). A tracked game that is covered is the user's window arrangement, not a launch problem.
