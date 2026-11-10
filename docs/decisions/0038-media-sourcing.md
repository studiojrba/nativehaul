# ADR 0038 — Media pass: slideshows never crop; trailers, screenshots and descriptions from official sources

**Status:** Accepted · 2026-11-09 (J.R's plan, confirmed Mon 18:48 EST)

## Context
J.R wants every game to show real media: a trailer when one exists, a slideshow of official screenshots, and the
official description. He reported a Kingdom Hearts II screenshot in the Builds slideshow cropped on all four sides
(the Commands menu clipped on the left, HUD text cut at the top, the minimap off the right).

The research behind the plan:
- Playnite gets trailers through its Extra Metadata Loader extension: Steam's trailer files first, then YouTube
  downloads through yt-dlp. **The yt-dlp leg is not copied.** It breaks YouTube's terms and breaks often.
- Playnite's descriptions come from IGDB.
- For Nintendo, blawar/titledb (on GitHub, regenerated from eShop data, keyed by NSUID) carries the official
  description and a `screenshots` array of direct Nintendo CDN images for each game.

## Decision

### 1. Slideshows never crop
- The media frame takes the shape of the slide it is showing: `MediaFit` sizes it as wide as the column allows,
  unless that would make it taller than a cap, in which case it narrows. Images use `scaledToFit`, so the frame
  and the image always have the same shape: nothing is cropped and nothing is letterboxed.
- `FittedMediaFrame` (Shared/DesignSystem) does the measuring and resizing. When the next slide has a different
  shape, the frame follows it in 0.35 s (instant under Reduce Motion).
- It is used in both slideshows: the Builds job showcase (cap 480 pt) and the game detail media (cap: the dial's
  hero height, 380 / 460 / 560 pt).
- **Visible consequence:** wide SteamGridDB heroes (about 3:1) now show at their own shape on the detail page, so
  they are shorter than the old fixed-height, cropped hero.
