# ADR 0059 — 0.1.1 polish round 1: onboarding order, honest trust lines, build log, curated shelves

## Context
J.R's 18 polish notes on the installed 0.1.0 (2026-11-13) and the Nov 13 Figma Make export. The main complaint was
fidelity drift from Make; several notes also asked for copy whose truth had to be checked first.

## Decision
- **Onboarding order:** welcome (with a trust beat) → games folder → quick scan (typing dots held ≥ 0.6 s) → Switch
  build tutorial (one folder, Begin build, demo build with its log, where builds go, launch, Good to know, library
  key) → emulators → couch or desk → closing beat with "Let's play". Music and interface sounds play from page 1.
- **Trust lines only where the build proves them.** nativehaul has no entitlements and calls no Accessibility, Full
  Disk Access, Input Monitoring or Screen Recording API, so "I only ask for what I actually need" ships. "I'm open
  source" is held back: the public repository's default branch (`production`) is older code with no LICENSE.
  nativehaul never downloads nxnative (ADR 0027), so the tutorial says it uses the user's own copy and never bundles,
  repackages or downloads it — not "from the author's official GitHub".
- **No shader pre-warming claim.** No nxnative checkout was available to verify what its shader step does, so the
  Shaders stage is renamed **Finishing** ("Packing it up as a Mac app"), and the Good to know note says a new area or
  effect "can hitch for a moment the first time" and "usually" settles — no promise.
- **Library key** replaces prod.keys / Switch keys / keys file in every user-facing string; Title ID reads Game ID.
  The help card's steps mention "a .keys file" as the one troubleshooting detail. Settings still shows the real path.
- **Emulators:** real names, real icons (installed apps) and the catalog's official sources (version and host shown).
  Installs reuse `ComponentUpdating`; each still stops for the signature verdict before going in. The Switch
  emulators (Make's Player One/Two) are not added to the catalog: their official sources need J.R's call.
- **Build log:** one shared panel (Make values), three-line default that never collapses, plus/minus to a 12-line
  height capped at 40% of the window, remembered per screen, fed by `BuildLogNarrator` from the engine's real stage
  lines. Pause stays hidden: the engine has no pause.
- **Home:** curated shelves from the user's own library only (`HomeShelfCurator`), each hidden below three games.
  No "Highest rated" (no rating is recorded). Drawn covers (Make's Art.tsx, stable per title) are the default art;
  official box art is never bundled or downloaded.
- **Screenshot harness:** DEBUG-only launch arguments over an in-memory demo library.

## Consequences
- Convenience wins: the tour does more by itself (folder preview, scan grouping, emulator offers ticked for you when
  none exist), and every claim it makes is backed by the build.
- When the licence lands on the public default branch, the welcome can add "I'm open source."
