# Changelog

All notable changes to nativehaul are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) (ADR 0051).

`scripts/release.sh` publishes the section for the version it releases as that release's notes, both on GitHub and
in the update window.

## [0.1.0] - 2026-11-13

The first public alpha: a shelf for Switch ports and emulator classics on Apple Silicon Macs. 0.1 to 1.0 is the
alpha line; 1.0 means couch mode complete, a clean-machine test passed and the polish list closed (ADR 0053).

### Added
- **New look:** the whole app redrawn in warm cream and charcoal, with dark appearance by default and a light one a
  click away (sidebar sun/moon or Settings → Appearance).
- **Home:** a hero carousel over the games you're playing, Continue playing, and the whole shelf at a glance.
- **Couch mode:** the same app at ten-foot scale, driven with a controller.
- **Sound:** gentle background music ("The Charm 68" by The Cynic Project, CC0) and interface sounds, each with its
  own switch in Settings → Audio.
- **Icon:** the n. mark.
- **Adoption:** existing nxnative builds and ROM folders join the shelf with no rebuilding. A build's Switch title
  ID is read from the app itself.
- **Switch builds:** an on-by-default build pipeline driven by your own copy of nxnative, using your own keys and
  game files.
- **Emulators:** RetroArch, Dolphin, PCSX2, melonDS and PPSSPP are detected, and ROMs are matched to systems and
  launched in your emulator.
- **Library:** Home, Jump Back In and Recently Added, plus collections, series and stats.
- **Playtime:** hours played are tracked per game, and every figure shows its source.
- **Guides:** linked from GameFAQs with credit to the author. HowLongToBeat figures are labelled as estimates.
- **Media:** official Nintendo eShop images and descriptions via titledb. With your own keys, IGDB and SteamGridDB
  fill in the rest, and trailers play on game pages.
- **RetroAchievements:** progress and badges for emulated games, using your own username and API key.
- **Updates:** nativehaul updates itself through Sparkle, with signed updates and a daily check that asks before
  installing.
- **Privacy:** no telemetry, no account and no sign-in. Keys you paste stay in your Keychain.

[0.1.0]: https://github.com/studiojrba/nativehaul/releases/tag/v0.1.0
