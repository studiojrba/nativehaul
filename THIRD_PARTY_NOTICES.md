# Third-party notices

nativehaul is © 2026 Studio Jrba inc. and released under the MIT License (see `LICENSE`).

This file lists every piece of third-party software that ships inside nativehaul, and the third-party tools,
data and services nativehaul works with but does not ship. The licence audit behind it is
`docs/LICENSE_AUDIT.md`.

## Shipped inside the app

nativehaul ships no third-party code other than what is listed in this section.

<!-- bundled-dependencies -->

## Used, never shipped

These are separate programs, data or services. nativehaul does not contain, modify or redistribute them.

### nxnative (MIT)
- Source: <https://github.com/seedds/nxnative>
- Licence: MIT.
- How nativehaul uses it: an external build engine the user installs themselves. nativehaul finds it on disk and
  runs it as a separate process. nativehaul never bundles, downloads or modifies it.

### Emulators (GPL, external apps only)
nativehaul launches emulated games through the user's own emulator apps. Each runs as its own application under its
own licence. When the user asks nativehaul to install one, it downloads the official release from the emulator's own
publisher and places it in `~/Applications`, unmodified. nativehaul never links to, embeds or redistributes emulator
code or cores.

| Emulator | Licence | Official source |
|---|---|---|
| RetroArch | GPL-3.0 | <https://www.retroarch.com> |
| Dolphin | GPL-2.0-or-later | <https://dolphin-emu.org> |
| PCSX2 | GPL-3.0-or-later | <https://pcsx2.net> |
| melonDS | GPL-3.0-or-later | <https://melonds.kuribo64.net> |
| PPSSPP | GPL-2.0-or-later | <https://www.ppsspp.org> |

### Data and services
- **titledb** (MIT, <https://github.com/blawar/titledb>): the Switch title list, downloaded at runtime for official
  names, descriptions and images. It is not shipped.
- **RetroAchievements** (<https://retroachievements.org>): achievement data via its web API, used only with the
  user's own username and API key.
- **IGDB** (<https://www.igdb.com>, via Twitch developer credentials) and **SteamGridDB**
  (<https://www.steamgriddb.com>): game metadata and artwork via their APIs, used only with the user's own keys.
  Images stay subject to their owners' rights.
- **YouTube**: trailers play in the privacy-enhanced embed (`youtube-nocookie.com`).
- **HowLongToBeat** and **GameFAQs**: link-out only. Nothing is scraped or embedded.

### Apple
SF Symbols and system fonts are used under Apple's licence terms for apps on Apple platforms.

## Not included, ever
Console keys, firmware, BIOS files, ROMs and game files. These always come from the user's own sources.
