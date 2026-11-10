# ADR 0040 — References (Floema, Kriss), light only, and the Kriss feel

**Status:** Accepted for J.R's look · 2026-11-09 (J.R, Mon 20:00 EST, including his ruling: light only). Not to merge
without his eyeball.

## References
J.R sent screenshots of two sites. In both, the pattern matters, not the product.

| Reference | What it sets |
|-----------|--------------|
| **Floema** (floema.com, the Trailhead kiosk product page) | The **detail page structure**: a sticky visual panel on the left, a calm scrolling column of content on the right, a thin divider between them, and a specs table with small labels and hairlines (ADR 0039). |
| **Kriss** (kriss.ai) | The **feel**: airy, bright but not sterile, fun but cozy. A whole scene washed in one soft colour, frosted floating panels, gentle motion. Also the **onboarding**: the product talks to you in short typed lines and moves you to the part it is describing. |

## Decision: one appearance, light
- **Dark appearance support is removed, not just un-defaulted.**
  - `Palette` now holds one value per role. The appearance-switching colour provider is gone.
  - The app sets `NSApplication.shared.appearance = .aqua`, and both windows use `preferredColorScheme(.light)`,
    so menus, alerts and sheets are light too.
  - Every render test renders light only.
  - `LightOnlyTests` fails if `darkAqua`, a dark colour scheme, or a dark branch comes back into the app's sources.
- **Warm neutrals:**
  - canvas `#FBF6EE`, surface `#FFFCF7`, sidebar `#F7F0E5`, warm near-black text `#2B231D`;
  - cream and off-white, red channel above blue, never blue-grey and never pure white (`PolishRulesTests`).
  - The accent stays Fetch orange, still spent only on Play, nav and links.

## Decision: the Kriss feel
- **Soft shadows instead of hard borders:** `surfaceCard` is a fill with a warm soft shadow, and its hairline
  stroke is gone. The shadow colour is a warm brown, never grey-black. Hairlines remain only as row dividers.
- **Frosted glass for floating elements:** the sidebar is `ultraThinMaterial` with warm cream laid over the blur,
  so it never reads as cold glass, and a soft shadow replaces its border.
- **Generously rounded:** radii went from 4/8/12/16 to 6/12/18/20.
- **Colour from game art, one soft colour per scene** (`SceneTint`, `SceneTintBackground`):
  - A screen names the art it is about. The detail page uses its cover; Home uses its featured hero, replacing
    Home's old ambient wash.
  - The shell washes the whole window, sidebar included, in a pastel of that art's sampled colour. It fades into
    the cream by three quarters of the way down and crossfades when the scene changes.
  - Pages inside the shell no longer paint their own canvas (`CanvasFill`), so the tint shows through. Sheets and
    the Settings window keep the cream canvas.
- **Motion:**
  - Content fades and rises gently into place (`riseIn`: 14 pt, 0.45 s ease-out, staggered, capped at under a
    second in total) on Home and the detail column.
  - The energy pass's one-signature-gesture budget and sub-second rule still hold.
  - Reduce Motion calms all of it: content just appears, and the tint changes without animating.
- **The dial survives** with the same three positions. It now varies the light theme's energy:
  - scale, as before;
  - the pastel's saturation (0.22 / 0.34 / 0.50);
  - its strength (the former ambient opacity).
- **Type stays big and friendly** per the dial.

## Decision: onboarding, rebuilt the Kriss way
It replaces the old first-run sheet, which is deleted with its checklist and modules. "Run setup again" in
Settings → General restarts it.
- **Retriever talks:**
  - Short first-person lines (at most three per step, each under 100 characters) appear one at a time, typed out at
    48 characters a second with a visible blinking caret while it "speaks" (`TypingText`, `TypingSchedule`).
  - They sit in a frosted bubble with a paw avatar (`GuideBubble`). No walls of text, no static pages.
- **Each step moves to the part of the app it describes** (`GuideStep`, `GuideHost`):

  | Step | Where it happens | What is highlighted |
  |------|------------------|---------------------|
  | Welcome | Home | — |
  | Folders | Library | The Library File menu. The step's button opens the real folder picker; chosen folders are added and scanned |
  | Detail and Play | A game page (one with cover art) | Play Now |
  | Port building | Builds | Add Job |
  | Steam sign-in and credential pastes | The Settings window, opened on its Steam tab, where the bubble appears | Sign in through Steam |
  | Farewell | Home | — |

  The highlight is a soft pulsing accent ring (`guideHotspot`).
- **Interactive:**
  - The user advances by pressing the step's button, or by using the highlighted control.
  - Every step can be skipped.
  - The tour can be exited at any point (×). An exited tour leaves a quiet "Continue the tour" pill that resumes it
    where it left off ("No thanks" puts it away for good).
  - Progress is remembered across launches (`GuideProgress` in UserDefaults).
- **Nothing in it is required** to use the app (ADR 0016).
  - It starts by itself only on a first launch.
  - Someone who finished or skipped the old sheet counts as finished.
  - The game page step is skipped when the library is empty.
  - The bubble never appears over a running game (ADR 0030).
- **Reduce Motion:** lines appear whole, with no typing and no caret, and the highlight does not pulse.
- **Accent budget:** the tour adds two sanctioned uses of the accent, the caret and the hotspot ring. The main
  bubble button is accent-tinted as a call to action.

## Consequences
- **Art-heavy areas stay dark:** game art and the media backdrop behind trailers are not re-coloured.
- **J.R won't see the tour by itself:** he finished the old first-run sheet, so it does not auto-start for him. He
  can open it from Settings → General → Run setup again.
- **Old dark-mode renders are stale:** comparison sheets and earlier renders that show dark mode are out of date.
  The current renders are light.
