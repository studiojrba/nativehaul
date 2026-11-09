# ADR 0037 — The Meebits energy pass, on a three-position dial

- Status: **proposed. Nothing merges on looks without J.R's eyeball.** Branch `feature/meebits-energy-pass`.
- J.R (Mon 2026-11-09 09:41 EST): "The overall look and feel of the app feels boring." At 09:55: "Don't be afraid to
  really lean into it. Nothing's permanent so we can dial it back or lean in even more."
- Related: ADR 0025 (design rules; item 7, what not to copy, recorded 2026-11-09), ADR 0035 (Home)

## The dial
- `DesignIntensity` has three positions: **As specced**, **Leaned in** and **Full send**.
- One `EnergyLevel` per position holds every value the pass turns up:
  - the tile field's strength and inset;
  - hover lift and art scale;
  - shelf, page-header and hero-title sizes;
  - hero heights (Home and detail);
  - the Home ambient wash.
- Views read the level from the environment (`\.designIntensity`), never literals, so tokens hold the system together
  at every position.
- **The app runs at Leaned in** until J.R picks. To try another position live without a rebuild:
  `defaults write com.studiojrba.Playrite design.intensity fullSend` (or `specced`), then relaunch.
  `defaults delete com.studiojrba.Playrite design.intensity` goes back to the default.
- **Renders** for J.R's call are in `docs/design/energy-pass/`:
  - `before/` holds the current stack tip;
  - `specced/`, `leaned-in/` and `full-send/` each hold Home and the All Games grid at 900, 1100 and 1280 (dark),
    plus 1100 light;
  - two side-by-side sheets compare the three positions.

## Audit against Ollie's list (state before this branch → what changed)
| # | Item | Before | Now |
|---|---|---|---|
| 1 | Content as saturated colour fields | **Gap.** Covers sat on the canvas; art colour appeared only as a faint hover wash. | Each cover sits on a field of its own art's sampled colour (deepening downward, 16 pt radius). No art means a neutral surface tile with no fake colour. Strength by dial. |
| 2 | Ambient colour on Home | **Done in F4** (full-bleed wash). | Strength by dial (0.45 / 0.65 / 0.9). |
| 3 | Graph-paper background | **Gap.** Flat canvas. | **Tried and rejected by J.R** (round 1, see below). Library and Home are back on the flat canvas at every position. |
| 4 | Type scale and mono data | **Partial.** Page headers were 28 pt heavy, but shelf and section headers were 17 pt semibold. Stragglers in proportional type: grid card lines, the Jump Back In time line, HLTB chip values, the hero-media counter, preflight file sizes, stat tile values, labelled-row values, info-list values, Steam's "last 2 weeks", rail counts. | Shelf headers use a new `.shelf` style (24 / 32 / 44 pt black rounded); page headers 34 / 44 / 56; Home hero title 60 / 80 / 104. Every straggler listed is now mono. Prose sentences containing a number stay proportional. |
| 5 | Accent discipline | **Gap.** The accent had crept into the Up Next part label, Stats rank numbers, earned badges, empty-state symbols, the build progress bar and percentage, and the cover selection ring. Play was a stock prominent button. | All pulled back to text colours. The accent is left on Play, the active nav item, links, the global control tint and the onboarding wordmark (Meebits spends it on the logo mark). A source-scan test (`EnergyPassTests`) keeps it there. Play has the app's one saturated gradient (accent into a deeper red) in a capsule, with other launch routes in a small menu beside it. |
| 6 | One signature motion | **Different.** Hover brightened a ring and laid a wash, and there was no lift. | Card hover lifts the card and scales the art inside its tile (3 / 5 / 8 pt, 1.03 / 1.05 / 1.08), consistently on every cover card. Nothing else reacts. Under Reduce Motion, hover does nothing. The hero crossfade is unchanged. |
| 7 | Game detail shape | **Partly centre-heavy.** A 280 pt hero, and the rail repeated the art as a big cover. | Hero 380 / 460 / 560 pt. The rail shows the cover only when there's no hero art, so the art appears once and the rail is the quiet narrow column. Info values are mono. **Still open:** playtime, sessions and guides still sit under the hero in the centre. Moving them into the rail is a bigger layout change, left for J.R's call. |

## Guardrails kept
- **Data readability:** data in mono at the same sizes as before, with the scrim under the hero text. The 900, 1100
  and 1280 layout guards pass.
- **Grid performance:**
  - each tile's colour comes from the existing cached `ArtworkTint` sample, one per image per session;
  - hover changes only transforms, so nothing reflows.
- **Transitions under a second:** the hero crossfade is 0.7 s and hover 0.15 s (tested).
- **No dead ends:** Home, the Installed filter and the empty states all offer a way on.
- **Reduce Motion:** no hover lift, no hero auto-advance and no fade.
- **Chrome stays monochrome:** the rail, toolbars and panels are unchanged. Colour comes from the art and the type.

## Tried and rejected
- **Graph-paper background texture (item 3).** Built as a hairline `Canvas` grid behind the library grid and Home,
  scaled by the dial. J.R, Mon 2026-11-09 13:31 EST, after living in the Leaned in build: "I like the direction for
  sure but I don't like that grid background."
  - Removed entirely at every dial position: the component, its two `EnergyLevel` values and both uses. Library and
    Home are back on the flat `Theme.canvas`.
  - **Don't bring it back in a later pass**, under this name or as another background pattern (dots, lines, noise).
    Surfaces stay flat; colour comes from the art and the type. `EnergyPassTests.noBackgroundTextureComesBack` guards
    the source.
  - Everything else in the pass stays as it was.
- The renders in `docs/design/energy-pass/` predate this ruling and still show the grid.

## Open for J.R
- **Which dial position.** The default is Leaned in.
- **"Electric indigo".** Ollie's item 5 names indigo, but that is Meebits' accent. Retriever's accent is Fetch orange
  (ADR 0025), and this pass keeps it. Switching to indigo is a two-colour palette change (`accent`, `accentDeep`) if
  J.R wants it.
- **ADR 0025's earlier hover rule** ("no lift, scale or shadow") is superseded by item 6 here, at J.R's direction.
- Whether to move playtime and sessions into the detail rail (item 7's remaining gap).
- The sample covers in the renders are flat gradients that match their own fields, so the fields read like thick
  borders. Real cover art contrasts with its averaged colour, so the mosaic will read stronger in the app.
