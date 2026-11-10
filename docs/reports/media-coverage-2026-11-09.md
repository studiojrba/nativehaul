# Media coverage — real library, 2026-11-09 (ADR 0038)

The first background metadata pass after relaunching J.R's copy on `feature/igdb-media-seam` (19:49–20:04 EST).
It compares a read-only snapshot of the store taken just before the relaunch with one taken after the pass went
quiet. Every fill is also in `Application Support/Playrite/Audit/audit.jsonl` (`metadata.fill`); there were no
`metadata.heroUpgrade` entries. IGDB had no credentials, so it was silently skipped: no requests, no errors.

## Totals
| Library | Games | Trailer | Slideshow | Description |
|---------|------:|--------:|----------:|------------:|
| Steam | 251 | **212** (was 0) | 236 (was 232) | 241 (was 237) |
| Switch ports | 24 | **3** (was 0) | **21** (was 3) | 23 (unchanged) |
| Other | 1 | 0 | 0 | 1 |

The 4 extra Steam slideshows and descriptions belong to 4 games Steam sync added during the same launch. Those
were their first metadata fills.

## Gained this pass, by source
| What | Steam store | titledb | IGDB |
|------|------------:|--------:|-----:|
| Trailers | 215 (212 Steam games + 3 ports with a Steam twin) | — (titledb has no video) | 0 (no credentials) |
| Slideshows | 4 | 18 ports (6 official screenshots each) | 0 |
| Descriptions | 4 | 0 | 0 |
| Hero swaps | — | 0 | — |

- **The 3 ports with a Steam trailer** (*Digimon Story Time Stranger*, *Final Fantasy Resonance*, *Legacy of Kain:
  Soul Reaver 1&2 Remastered*) matched Steam, so they took Steam's set and titledb was not asked.
- **No titledb description fills:** 23 of 24 ports already had an imported description, and fills never overwrite.
  *Ocarina of Time* has none, but it is not in titledb.
- **No hero swaps:** all 22 SteamGridDB port heroes are already 1920–3840 px wide, so the official 1920×1080 key art
  is not clearly better. *Final Fantasy Resonance*'s 1438 px hero is official Steam art, which is never replaced.

## Switch ports and titledb (title ID → NSUID)
- **Built ports:** 15 of 18 matched by title ID (read from the built app's `org.nxnative.<id>` bundle ID).
- **Ports with no built app:** 6 of 6 matched by exact title.
- **Total:** 21 of 24 library ports have a titledb record. 3 of those 21 took Steam's media instead, as above.
- **Not in titledb at all:**
  - *Fire Emblem: Fortune's Weave* (`04007EF01F8AE000`)
  - *Pokémon Pokopia* (`0400A3A01EE4C000`)
  - *The Legend of Zelda: Ocarina of Time* (`0400486024DEC000`)

## Still missing
**Switch ports**
- **Trailer: 21 ports.** Every port without a Steam twin. IGDB fills these once J.R adds Twitch credentials.
- **Slideshow:** *Fire Emblem: Fortune's Weave*, *Pokémon Pokopia*, *Ocarina of Time* (IGDB candidates).
- **Description:** *Ocarina of Time*.

**Steam: 39 library rows (37 titles; two titles appear twice) without a trailer.** Most are tools, betas, test servers, delisted or very old store pages with
no store movie. Each is asked again once per launch.

- Arma 2: Operation Arrowhead Beta (Obsolete) | missing: trailer, slideshow, description
- BioShock 2 | missing: trailer
- BioShock 2 Remastered | missing: trailer
- BioShock Remastered | missing: trailer
- Call of Duty (hub) | missing: trailer, slideshow
- Call of Duty: Modern Warfare (2019) | missing: trailer, slideshow
- DOOM (2016) | missing: trailer, slideshow
- F.E.A.R. 3 | missing: trailer
- FINAL FANTASY XIII-2 | missing: trailer
- Fallout 76 Public Test Server | missing: trailer, slideshow, description
- Garry's Mod | missing: trailer
- Gears of War: E-Day Multiplayer Beta | missing: trailer, slideshow, description
- Insurgency | missing: trailer
- KINGDOM HEARTS III + Re Mind | missing: trailer, slideshow
- Miscreated: Experimental Server | missing: trailer, slideshow, description
- Mortal Kombat Komplete Edition | missing: trailer
- Red Dead Redemption 2 | missing: trailer
- Rocksmith | missing: trailer
- Rome: Total War - Alexander | missing: trailer
- Rust - Staging Branch | missing: trailer, slideshow, description
- S.T.A.L.K.E.R.: Clear Sky | missing: trailer
- S.T.A.L.K.E.R.: Shadow of Chernobyl | missing: trailer
- Sid Meier's Civilization IV | missing: trailer
- Sid Meier's Civilization IV: Warlords | missing: trailer
- Sleeping Dogs™ | missing: trailer
- Stomping Land | missing: trailer, slideshow, description
- THE FINALS PLAYTEST | missing: trailer, slideshow, description
- The Vanishing of Ethan Carter Redux | missing: trailer, description
- The Witcher 3: Wild Hunt | missing: trailer, slideshow
- Thief Gold | missing: trailer
- Thief: Deadly Shadows | missing: trailer
- Thief™ II: The Metal Age | missing: trailer
- Total War Battles: SHOGUN | missing: trailer, slideshow, description
- Total War: SHOGUN 2 | missing: trailer, slideshow, description
- Warhammer 40,000: Dawn of War - Dark Crusade | missing: trailer
- Warhammer 40,000: Dawn of War - Winter Assault | missing: trailer
- Wreckfest Throw-A-Santa + Sneak Peek 2.0 | missing: trailer, slideshow

**Other:** *Chaos Zero Nightmare* has no trailer or slideshow (not a Steam or Switch game, so no media source
applies).
