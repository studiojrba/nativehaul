# ADR 0025 — UI polish pass: neutral system, one saturated pop, colour from the games

**Status:** Accepted · 2026-11-07 · J.R's call to move the design phase forward

## Context
J.R read the design research and asked for "something nice and ultra polished" to see when he wakes up, moving the
design phase forward ahead of Figma. He gave three inputs, summarised from the research report on the VM side:

1. **Benchmarks:**
   - **Linear** for the token system: near-black canvas `#08090A`, surfaces `#101113` / `#16171B`, hairlines
     `#1F2023` instead of shadows, a sidebar dimmer than the canvas, 13 pt UI text, 8 pt rhythm.
   - **Steam** for poster-grid restraint: title plus one quiet line.
   - **Infuse** for the detail hero's breathing room (and as the warning against a crowded rail).
   - **Steam Replay** for a Stats page told as a story rather than a wall of KPI cards.
2. **Colour amendment:** don't land boring-minimal.
   - One signature accent used sparingly (~5% of a screen): warm and playful, not corporate blue.
   - Art-derived tints: a hero glow and a hover wash, in the Apple TV / Steam pattern.
   - Status colours stay muted. "Colour is garnish, not wallpaper."
3. **Character reference: the (Not Boring) apps** — (Not Boring) Weather and (Not Boring) Habits by Not Boring
   Software, Apple Design Award winners. J.R's note: "clean with pop."
   - A monochrome foundation.
   - Bold, oversized, tight type.
   - Exactly one loud, saturated colour per surface.

4. **Meebits deep-dive** (a full interactive walk of every page, with hovers tested), distilled by Ollie:
   - **Chrome stays monochrome**, with exactly **one electric accent** (theirs is indigo-violet), spent only on the
     logo mark, the active nav state and links. This confirms our single Fetch-orange pop.
   - **Colour comes from the content, full stop.** Every collection card is the same saturated tile holding one
     object, with only its ID in monospace beneath. This validates our grid restraint; our one quiet line is already
     more than Meebits shows.
   - **Type pairing:** huge bold grotesque headlines (4–5× body size) plus a **monospace face for all data**
     (counts, stats, labels). Candidate for Retriever: playtime, install size, HLTB numbers and stats in mono.
   - **Hover discipline:** almost none. A pointer cursor plus one tiny signal (an accent bar beside the active nav
     item; black buttons lighten one shade). No lift, scale or shadow on cards; our hover ring should be equally
     quiet.
   - **Motion budget:** one signature gesture (theirs is a full-screen branded transition; the characters idle-bob,
     and the detail hero rotates on drag) instead of animating every control.
   - **Detail page shape** confirms ours: a quiet narrow info column (mono stats, two pill actions, primary black and
     secondary white) beside one huge full-height hero card. Buttons are pills everywhere; cards are about 16 px
     radius, the hero about 20 px.
   - **Item 7 — what NOT to copy** (from Ollie's walk; it arrived cut off in November and was supplied by J.R and
     Ollie on 2026-11-09):
     - **(a) No slow transitions.** Meebits' page transition takes about 8 seconds. Every transition in Retriever stays
       fast, well under a second.
     - **(b) No surface breaks the design system.** Meebits' shop abandons its own design system completely. No
       Retriever surface, the Builds pages included, may step outside the token system for a one-off look.
     - **(c) No dead ends.** Meebits has dead 404 pages with no way back. Every empty state in Retriever offers an
       action or a way back.
   These rules were recorded after the pass shipped. Applying them (mono for data, a quieter hover, pill buttons,
   16/20 px radii, one motion gesture) is follow-up work, not done in this branch.

This pass is **visual only**: no behaviour, data or navigation changes. Hard constraints: the 900/1100/1280 layout
guards stay green, every test passes, lint stays clean, and the renders are inspected before pushing.

## Decision
- **Tokens:**
  - `Palette` holds dark and light hex pairs for every role (canvas, sidebar, surface, surfaceRaised, hairline,
    hairlineStrong, three text levels, accent, onAccent, muted status colours).
  - `Theme` maps roles to appearance-following colours.
  - `DesignTokens` gains `TypeScale` (11 / 13 / 15 / 17 / 22 / 26 / 28 / 34 / 44 pt), display typography with tight
    tracking, `ArtTint` and a selection opacity.
  - Views still contain no visual literals. `Palette.swift` is the colour source, so it alone carries a scoped,
    commented exception to the magic-number lint rule.
- **The signature accent: "Fetch orange"**, `#FF5A1F` dark and `#F24E12` light, with near-black `#0B0B0C` text on
  it.
  - Why this colour: a saturated, warm red-orange in the (Not Boring) spirit (Weather's red sun), a little playful,
    for a game shelf named after a dog. It pops hard on near-black and still holds on white.
  - It is used only on the Play button, the active rail item, selection rings, the app tint (system selection,
    toggles, progress), links, empty-state symbols, the Stats rank numbers and "Retriever" in the welcome.
  - Everything structural stays neutral. A test checks that the structural colours are near-chroma-free and that the
    accent is the one saturated colour.
- **Type with confidence, data kept calm:**
  - Big, tight, rounded display type is used for page and section headers on the Stats page, the game title, empty
    states, onboarding titles and the welcome. "Hey! I'm **Retriever**." is 44 pt black, with the name in the accent.
  - Dense panels (detail sections, rows, info lists, the Builds queue) keep calm 13 pt text and `SectionHeader`'s
    quiet `.panel` style.
- **Poster grid:**
  - Each card shows the title and **one** state-driven line: the largest real playtime figure with its source label
    ("66h 42m · SteamSynced"), or the status. Sources are never added together.
  - The status pill has left the card.
  - The radius is consistent, a hairline ring brightens on hover, an accent ring marks selection, and the hover wash
    is sampled from the card's own art. There are no shadows and no badges on the artwork.
- **Icon rail:**
  - Verified: hover-expand is an overlay (the content is inset by the collapsed width only), so it never reflows or
    jitters the grid.
  - It now sits on the dimmer sidebar surface with a hairline edge instead of a shadow.
  - Only the active item uses the accent: a soft wash plus an accent icon.
- **Detail page:**
  - The hero gets an ambient glow from the game's own art (`ArtworkTint`): average colour, lifted to a minimum
    saturation and a fixed brightness. It is a blurred gradient at 32% that spans the centre column, drawn as a
    background, so layout and text contrast are untouched.
  - HLTB chips are monochrome: canvas fill, hairline, primary value, still labelled "HLTB estimate".
  - Hairlines replace dividers. The right rail keeps exactly its sections, with tighter 12 pt spacing and hairline
    rules between groups.
- **Stats:**
  - The page leads with **Most played**: up to five games with art, ranked by each game's **largest single real
    figure** (never a sum across sources, never HLTB), with the rank numbers in the accent.
  - The totals and the rest follow, as one story.
  - Presentation data only: the snapshot now carries the cover path, and the ranking derives from the same numbers.
- **Consistency:**
  - `EmptyStateView` (accent symbol, display title, calm sentence) replaces the system empty states on the library,
    root, Builds and switched-off screens.
  - The canvas background runs across screens. Builds, quick-list and rail panels share the surface.
  - Tags are neutral and outlined.
  - Status tints are muted. "Playing" moved off the accent to a muted amber, so the accent stays exclusive.
- **Renders:**
  - `PolishRenderTests` renders the grid and detail page at 900, 1100 and 1280, plus Stats, the welcome and the
    Builds page, in dark and light, with generated stand-in artwork so the tints show.
  - All were inspected before pushing; fixes followed (the glow edges, link colour, display-header captions).
  - A curated, downscaled set is in `docs/design/ui-polish/`.

## Consequences
- The app reads as one designed thing: calm and neutral at arm's length, with colour from the games and one orange
  pop where the action is.
- Figma can still re-skin it through `Palette`, `Theme` and `DesignTokens` alone.
- **Not verified live:** the renders use stand-in art in an offscreen window (which reserves a scrollbar gutter and
  draws an inactive-window selection). J.R's real library with real covers is the true check.
- The app rename stays queued after this.
