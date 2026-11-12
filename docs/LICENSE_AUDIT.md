# Licence audit

**Last run:** 2026-11-10, for the 1.0 release track (ADR 0049). Re-run it whenever a dependency, bundled resource or
network host changes.

## Result
- nativehaul is MIT-licensed, © 2026 Studio Jrba inc. (`LICENSE`).
- **Nothing GPL is bundled.** No GPL or other copyleft code is compiled into, linked into or shipped inside the app.
- Emulators (all GPL) are **external launches only**: separate apps the user owns, started through Launch Services.
  When the user asks, nativehaul downloads an official, unmodified release from the emulator's publisher. That is
  not redistribution by nativehaul.
- Every third-party item is listed in `THIRD_PARTY_NOTICES.md`, and that file and `LICENSE` ship inside the app.

## What was checked

| Item | Kind | Licence | Shipped? | Notes |
|---|---|---|---|---|
| Sparkle 2.10.1 (SwiftPM, exact version) | Code | MIT (+ BSD-2-Clause bsdiff, MIT sais-lite, zlib ed25519, BSD-2-Clause SUSignatureVerifier) | Yes | The only bundled framework. Full licence in the notices. A test checks the app's Frameworks folder against this audit. |
| `ComponentCatalog.json` | Data | Ours (MIT) | Yes | Written by us: emulator names, official URLs, version pins. |
| `SwitchTitleVersions.json` | Data | Ours (MIT) | Yes | Ships empty (schema only). |
| `TroubleshootingKnowledgeBase.json` | Data | Ours (MIT) | Yes | Written by us. |
| App icon (`Assets.xcassets/AppIcon`) | Asset | Ours (supplied by J.R for nativehaul) | Yes | The only image that ships. |
| Fonts, other images | Assets | n/a | No | No custom fonts or other images ship; the UI uses SF Symbols and system fonts (Apple terms). |
| nxnative (`seedds/nxnative`) | Tool | MIT | **No** | User-installed, found on disk, run as a separate process. |
| RetroArch | App | GPL-3.0 | **No** | External launch / optional official download. |
| Dolphin | App | GPL-2.0-or-later | **No** | External launch / optional official download. |
| PCSX2 | App | GPL-3.0-or-later | **No** | External launch / optional official download. |
| melonDS | App | GPL-3.0-or-later | **No** | External launch / optional official download. |
| PPSSPP | App | GPL-2.0-or-later | **No** | External launch only. |
| titledb (`blawar/titledb`) | Data | MIT | **No** | Downloaded at runtime. |
| RetroAchievements, IGDB, SteamGridDB | Services | API terms | **No** | User's own keys; artwork stays its owners'. |

## Method
1. List every SwiftPM package and framework in `project.yml` and in the built app's `Contents/Frameworks`.
2. List every file in the app's `Contents/Resources`.
3. Grep the source for every external host (enforced by `ReleasePolicyTests`, against `docs/PRIVACY.md`).
4. Look up each third-party licence at its source (GitHub's licence detection, then the LICENSE file).
