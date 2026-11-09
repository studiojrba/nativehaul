# ADR 0032 — "Keep games in front": an opt-in assist (rejected), and what macOS cannot do

- Status: **Layer 2 rejected by J.R** (2026-11-08). Not built and not to be built. Layer 3, the honesty constraint and
  copy rule, stands.
  - J.R's reasoning: a game going blank when it loses focus is normal macOS behaviour, and one click on its window
    already fixes it. Don't fix what isn't broken.
  - Layer 1, the clean handoff in ADR 0030, was approved separately in its minimal form.
- Proposed: 2026-11-07 19:28 EST (J.R's question)
- Recorded on: `feature/nxnative-first-launch-guidance`
- Related: ADR 0030 (Layer 1, the clean handoff), ADR 0016 (zero-tinker), ADR 0021 (features ship on)

## Context
J.R: "Is there any way we can ensure that if games are launched in Retriever, that they stay the top most window?"
Tonight's black screens (QA Finding #6) came from the game losing focus around launch. The question breaks into three
layers:
- **Layer 1:** what Retriever can guarantee with no permission. Scoped in the ADR 0030 amendment.
- **Layer 2:** what it could do with extra trust. This ADR.
- **Layer 3:** what macOS doesn't allow at all. This ADR.

## Layer 2 — opt-in assist using the Accessibility API (REJECTED; kept for the record)
**Mechanism:**
- With Accessibility (AX) trust, an app can bring another app forward: set `kAXFrontmostAttribute` on the target's
  application element, and `AXRaise` its main window. Window managers use the same mechanism.
- Plain `NSRunningApplication.activate` is non-authoritative since macOS 14 (cooperative activation). The system may
  decline it, so it can't be the basis of a guarantee.

**Scope, if J.R ever approves it:**
- **Opt-in only:** off by default, enabled in Settings, with a plain explanation of what Accessibility allows. It is
  never required for basic play (zero-tinker rule, ADR 0016). Layer 1 alone has to give a working one-click launch.
  This is the one deliberate exception to "features ship on" (ADR 0021), because it needs a heavy-trust permission.
- **Guard window only:**
  - The assist re-asserts the game only if something else takes the front within a short guard window after launch,
    about 10 s, a named constant.
  - Within that window it re-asserts at most a few times, then gives up and logs it.
- **Never fights the user:**
  - After the guard window, Retriever never re-asserts.
  - Inside it, a deliberate user switch (Cmd-Tab, clicking another app or the Dock) ends the guard at once.
- **Audited:** every re-assertion is noted in the audit log, with the app that took the front.

**Constraints to respect:**
- **Accessibility is heavy trust.** An AX-trusted app can observe and drive other apps' UI, input included. Asking
  for it has to be rare, explained and reversible, and Retriever must use only the two calls above.
- **The grant is tied to the binary and path (TCC).** Ad-hoc-signed development rebuilds change the code identity, so
  macOS asks again after each rebuild. This is another reason the assist waits for stable Developer ID signing.
- **Sandboxed distribution can't use it.** A Mac App Store build can't request Accessibility for this, so the assist
  exists only in a directly distributed build.
- **No Full Disk Access and no other permissions** come with it (ADR 0026).

**If approved, it needs:**
- an `AXForegrounding` protocol (live: AXUIElement calls; mock for tests);
- a `GameFrontGuard` driven by the ADR 0030 handoff coordinator;
- a Settings opt-in with a trust check;
- tests for: re-assert inside the guard window, no action after it, a user switch ending the guard, the attempt cap,
  and doing nothing when not trusted.

## Layer 3 — the honesty constraint
- macOS has no public API that pins **another app's** window always on top. Window levels belong to the app that owns
  the window. Retriever can't raise a game's window level, float it, or keep it above other apps.
- **Copy rule:** UI and docs never promise that games "stay on top", "always in front" or "pinned". The promises are:
  - the clean handoff (Layer 1): Retriever gets out of the way and never takes the focus;
  - the guarded assist (Layer 2), only if built and enabled: right after launch, Retriever puts the game back in
    front if something else grabs it.

## Consequences
- J.R's question gets an honest answer:
  - Layer 1 guarantees the moment of launch, which is where tonight's failures happened.
  - Layer 2 would guard the first seconds, opt-in, with Accessibility.
  - Nothing can make a game permanently topmost.
- The copy rule is recorded in CLAUDE.md so no screen over-promises.
- Layer 2 is rejected (J.R, 2026-11-08): no Accessibility permission is requested, and no keep-in-front code is
  written. The design above is kept only as the record of what was considered and why it was declined.
